# frozen_string_literal: true

module Pipette
  class ProcessEad
    include ApplicationHelper
    include DownloadEad

    def process(aspace_id:, is_deletion:, force:)
      resource_record = get_resource_info(resource_id: aspace_id)
      AspaceErrors.new.errors_check(resource_record: resource_record, aspace_id: aspace_id)

      record_for_status_info = {
        collection_id: resource_record['ead_id'],
        collection_title: resource_record['title']
      }
      collecting_units = []
      notes = []
      resource = RecordEad.new

      resource_record['classifications'].each do |classification|
        classification_uri = classification['ref'].to_s
        collection = collecting_unit_identifier(classification_uri: classification_uri)
        collecting_unit = collecting_unit_info(classification_uri: classification_uri)
        pipette_record = Pipette::Resource.find_by(
          pipette_collecting_unit_id: collecting_unit.id,
          resource_identifier: resource_record['ead_id']
        )
        should_index = is_deletion || should_force?(force) ||
                       needs_indexing?(pipette_record&.last_indexed_on, resource_record['user_mtime'])

        if should_index
          if is_deletion
            delete_xml(resource_record['ead_id'], collection)
          else
            ead_xml = get_xml(aspace_id: aspace_id)
            write_xml(resource_record['ead_id'], collection, ead_xml)
          end

          resource.update_database(collecting_unit.id, resource_record, is_deletion)
        end

        collecting_unit_name = collecting_unit.collecting_unit.upcase
        collecting_units << collecting_unit_name
        notes << indexing_note(should_index, collecting_unit_name)
      end

      record_for_status_info[:collecting_unit] = collecting_unit_list(collecting_units)
      record_for_status_info[:note] = notes.join('<br/>')
      record_for_status_info
    end

    # "force" should come in as a string since it's from a form
    def should_force?(force)
      force.to_s.downcase == 'true'
    end

    def indexing_note(was_indexed, collecting_unit_name)
      return '' if was_indexed

      "Indexing skipped for #{collecting_unit_name}. Archy indexing more recent than last Aspace update"
    end

    def collecting_unit_info(classification_uri:)
      CollectingUnit.find_by(collecting_unit: collecting_unit_identifier(classification_uri: classification_uri))
    end

    def collecting_unit_identifier(classification_uri:)
      collecting_unit = classification_uri.split('/')
      collecting_unit = Pipette::AspaceClient.client.get("/classifications/#{collecting_unit.last}").parsed
      collecting_unit['slug']
    end

    def collecting_unit_list(collections)
      collections.join('; ')
    end
  end
end
