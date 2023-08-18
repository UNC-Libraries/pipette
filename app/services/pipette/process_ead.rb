# frozen_string_literal: true

module Pipette
  class ProcessEad
    include DownloadEad

    def process(aspace_id:)
      resource_record = get_resource_info(resource_id: aspace_id)
      AspaceErrors.new.errors_check(resource_record: resource_record, aspace_id: aspace_id)

      resource = RecordEad.new
      resource_record['classifications'].each do |classification|
        classification_uri = classification['ref'].to_s
        collection = collecting_unit_identifier(classification_uri: classification_uri)
        ead_xml = get_xml(aspace_id: aspace_id)
        write_xml(resource_record['ead_id'], collection, ead_xml)
        collecting_unit = collecting_unit_id(classification_uri: classification_uri)
        resource.update_database(collecting_unit, resource_record)
      end
    end

    def collecting_unit_id(classification_uri:)
      collection = CollectingUnit.find_by(collecting_unit: collecting_unit_identifier(classification_uri: classification_uri))
      collection.id
    end

    def collecting_unit_identifier(classification_uri:)
      collecting_unit = Pipette::AspaceClient.client(use_default_repo: false).get(classification_uri).parsed
      collecting_unit['slug']
    end
  end
end
