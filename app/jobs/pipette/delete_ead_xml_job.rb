# frozen_string_literal: true

require 'pipette/errors'

module Pipette
  class DeleteEadXmlJob < ApplicationJob
    queue_as :delete

    def perform(aspace_id)
      Rails.logger.info "Starting deletion of EAD for finding aid with ArchivesSpace ID: #{aspace_id}"
      job = Pipette::ProcessEad.new.process(aspace_id: aspace_id, force: true, is_deletion: true)

      # Store info about the job for display on job status board
      store collecting_unit: job[:collecting_unit]
      store collection_id: job[:collection_id]
      store collection_title: job[:collection_title]
      Rails.logger.info "EAD deleted for finding aid with ArchivesSpace ID: #{aspace_id}"
    rescue Errno::ENOENT => e
      Rails.logger.error("Unable to delete EAD for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.message}")
    rescue Git::FailedError => e
      Rails.logger.error("Unable to commit deletion of EAD xml for finding aid with ArchivesSpace ID to git: #{aspace_id}. Reason: #{e.message}")
    end
  end
end