# frozen_string_literal: true

require 'pipette/errors'

module Pipette
  class DeleteEadXmlJob < ApplicationJob
    queue_as :delete

    def perform(id, soft = false)
      Rails.logger.info "Starting deletion of EAD for finding aid with ArchivesSpace ID: #{id}"
      job = if soft
        Pipette::SoftProcessEad.delete(id)
      else
        Pipette::ProcessEad.new.process(aspace_id: id, is_deletion: true)
            end


      # Store info about the job for display on job status board
      store collecting_unit: job[:collecting_unit]
      store collection_id: job[:collection_id]
      store collection_title: job[:collection_title]
      Rails.logger.info "EAD deleted for finding aid with ArchivesSpace ID: #{id}"
    rescue Errno::ENOENT => e
      Rails.logger.error("Unable to delete EAD for finding aid with ArchivesSpace ID: #{id}. Reason: #{e.message}")
    rescue Git::FailedError => e
      Rails.logger.error("Unable to commit deletion of EAD xml for finding aid with ArchivesSpace ID to git: #{id}. Reason: #{e.message}")
    end
  end
end