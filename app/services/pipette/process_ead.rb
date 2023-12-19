# frozen_string_literal: true

module Pipette
  class ProcessEad
    include DownloadEad

    def process(aspace_id:, is_deletion:)
      resource_record = get_resource_info(resource_id: aspace_id)
      AspaceErrors.new.errors_check(resource_record: resource_record, aspace_id: aspace_id)

      record_for_status_info = {
        collection_id: resource_record['ead_id'],
        collection_title: resource_record['title']
      }
      collecting_units = []
      resource = RecordEad.new

      resource_record['classifications'].each do |classification|
        classification_uri = classification['ref'].to_s
        collection = collecting_unit_identifier(classification_uri: classification_uri)

        if is_deletion
          delete_xml(resource_record['ead_id'], collection)
        else
          ead_xml = get_xml(aspace_id: aspace_id)
          write_xml(resource_record['ead_id'], collection, ead_xml)
        end

        collecting_unit = collecting_unit_info(classification_uri: classification_uri)
        resource.update_database(collecting_unit.id, resource_record, is_deletion)

        collecting_units << collecting_unit.collecting_unit.upcase
      end

      record_for_status_info[:collecting_unit] = collecting_unit_list(collecting_units)
      record_for_status_info
    end

    def collecting_unit_info(classification_uri:)
      CollectingUnit.find_by(collecting_unit: collecting_unit_identifier(classification_uri: classification_uri))
    end

    def collecting_unit_identifier(classification_uri:)
      repo = classification_uri.split('/')
      collecting_unit = Pipette::AspaceClient.client.get("/classifications/#{repo.last}")
      JSON.parse(collecting_unit)['slug']
    end

    def collecting_unit_list(collections)
      collections.join('; ')
    end
  end
end
