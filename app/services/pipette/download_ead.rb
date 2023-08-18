# frozen_string_literal: true

module Pipette
  module DownloadEad
    def get_resource_info(resource_id:)
      Pipette::AspaceClient.client.get("resources/#{resource_id}").parsed
    end

    def get_xml(aspace_id:)
      query_params = {
        include_daos: true,
        repo_id: 2,
        numbered_cs: true,
        include_unpublished: false,
        ead3: false,
        print_pdf: false
      }
      Pipette::AspaceClient.client.get("resource_descriptions/#{aspace_id}.xml", query: query_params, timeout: 1200)
                           .body.force_encoding('UTF-8')
    end

    def write_xml(ead_id, collecting_unit, resource_xml)
      # set_branch
      FileUtils.mkdir_p "#{ENV['FINDING_AID_DATA']}/#{collecting_unit}"
      File.write("#{ENV['FINDING_AID_DATA']}/#{collecting_unit}/#{ead_id}.xml", resource_xml)
    end

    def set_branch
      system("git checkout #{ENV['FINDING_AID_BRANCH']}", chdir: ENV['FINDING_AID_DATA'])
      system("git pull origin #{ENV['FINDING_AID_BRANCH']}", chdir: ENV['FINDING_AID_DATA'])
    end
  end
end
