# frozen_string_literal: true

module Pipette
  class RecordEad
    def update_database(collecting_unit, resource)
      pipette_record = Resource.find_by(pipette_collecting_unit_id: collecting_unit, resource_identifier: resource['ead_id'])
      if pipette_record.nil?
        create_resource_record(collecting_unit, resource)
      else
        edit_resource_record(pipette_record, collecting_unit, resource)
      end
    end

    def create_resource_record(collecting_unit, resource)
      Resource.create(pipette_collecting_unit_id: collecting_unit,
                      aspace_id: aspace_id(resource['uri']),
                      resource_name: resource['title'],
                      resource_identifier: resource['ead_id'],
                      last_updated_on_aspace: format_aspace_date(resource['system_mtime']),
                      last_indexed_on: date_indexed)
    end

    def edit_resource_record(pipette_record, collecting_unit, resource)
      Resource.update(pipette_record.id, pipette_collecting_unit_id: collecting_unit,
                                         aspace_id: aspace_id(resource['uri']),
                                         resource_name: resource['title'],
                                         resource_identifier: resource['ead_id'],
                                         last_updated_on_aspace: format_aspace_date(resource['system_mtime']),
                                         last_indexed_on: date_indexed)
    end

    private

    def aspace_id(resource_uri)
      resource_uri.split('/').last
    end

    def format_aspace_date(date_value)
      DateTime.parse(date_value).strftime('%Y-%m-%d %H:%M:%S.%6N')
    end

    def date_indexed
      DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%6N')
    end
  end
end
