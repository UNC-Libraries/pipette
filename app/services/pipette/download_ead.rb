# frozen_string_literal: true

require 'git'

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
      collecting_unit_path = collecting_unit_dir_path(collecting_unit)
      file_path = "#{collecting_unit_path}/#{ead_id}.xml"

      FileUtils.mkdir_p collecting_unit_path
      File.write(file_path, resource_xml)

      commit_to_git(file_path)
    end

    def delete_xml(ead_id, collecting_unit)
      file_path = "#{collecting_unit_dir_path(collecting_unit)}/#{ead_id}.xml"
      FileUtils.remove_file(file_path)
      delete_pdf(ead_id, collecting_unit)
      commit_to_git(file_path)
    end

    private

    # This seems to cause the download_ead tests to fail if there's no rescue block
    # as it's trying to find a non-existent temp file. Not sure what's going on there
    def delete_pdf(ead_id, collecting_unit)
      file_path = "#{ENV['FINDING_AID_PDF_PATH']}/#{collecting_unit}/#{ead_id}.pdf"
      FileUtils.remove_file(file_path)
    rescue Errno::ENOENT
      Rails.logger.warn "PDF deletion error: Unable to delete #{file_path}. The file does not exist"
    end

    def commit_to_git(file_path)
      return if Rails.env.test?

      branch_name = ENV['FINDING_AID_BRANCH'].to_s
      repo = Git.open(ENV['FINDING_AID_DATA'].to_s, log: Rails.logger)
      repo.branch(branch_name).checkout
      # repo.fetch(repo.remote('origin'), branch_name) # Pull in any upstream changes first
      repo.add(file_path)
      repo.commit("Adding/Updating EAD #{file_path}")
      # Only push to git from a server, not the VM. APP_NAME should always be an empty string on the VM
      repo.push(repo.remote('origin'), branch_name) unless ENV['APP_NAME'].blank?
    end

    def collecting_unit_dir_path(collecting_unit)
      "#{ENV['FINDING_AID_DATA']}/#{collecting_unit}"
    end
  end
end
