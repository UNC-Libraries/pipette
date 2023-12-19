# frozen_string_literal: true

require 'git'

module Pipette
  module DownloadEad
    def get_resource_info(resource_id:)
      data = Pipette::AspaceClient.client.get("resources/#{resource_id}")
      JSON.parse(data)
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
      p = Pipette::AspaceClient.client.get("resource_descriptions/#{aspace_id}.xml", query: query_params, timeout: 1200)
      p.body.force_encoding('UTF-8')
    end

    def write_xml(ead_id, collecting_unit, resource_xml)
      return if Rails.env.test?

      collecting_unit_path = collecting_unit_dir_path(collecting_unit)
      file_path = "#{collecting_unit_path}/#{ead_id}.xml"

      FileUtils.mkdir_p collecting_unit_path
      File.write(file_path, resource_xml)

      commit_to_git(file_path)
    end

    def delete_xml(ead_id, collecting_unit)
      return if Rails.env.test?

      file_path = "#{collecting_unit_dir_path(collecting_unit)}/#{ead_id}.xml"
      FileUtils.remove_file(file_path)
      delete_pdf(ead_id, collecting_unit)
      commit_to_git(file_path)
    end

    def delete_pdf(ead_id, collecting_unit)
      file_path = "#{ENV['FINDING_AID_PDF_PATH']}/#{collecting_unit}/#{ead_id}.pdf"
      FileUtils.remove_file(file_path)
    end

    def commit_to_git(file_path)
      branch_name = ENV['FINDING_AID_BRANCH'].to_s
      repo = Git.open(ENV['FINDING_AID_DATA'].to_s, log: Rails.logger)
      repo.branch(branch_name).checkout
      repo.fetch(repo.remote('origin'), branch_name) # Pull in any upstream changes first
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
