# frozen_string_literal: true

require 'pipette/errors'

module Pipette
  class ProcessEadXmlJob < ApplicationJob
    queue_as :aspace

    def perform(aspace_id, force)
      Rails.logger.info "Starting download of EAD for finding aid with ArchivesSpace ID: #{aspace_id}"
      job = Pipette::ProcessEad.new.process(aspace_id: aspace_id, is_deletion: false, force: force)

      # Store info about the job for display on job status board
      store collecting_unit: job[:collecting_unit]
      store collection_id: job[:collection_id]
      store collection_title: job[:collection_title]
      store note: job[:note]
      Rails.logger.info "EAD written to file for finding aid with ArchivesSpace ID: #{aspace_id}"
    rescue Pipette::AspaceRequestError,
           Pipette::ClassificationError,
           Pipette::UnpublishedError => e
      Rails.logger.error("Unable to download and process EAD xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.message}")
    rescue MultiXml::ParseError => e
      Rails.logger.error("Unable to read xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.backtrace}")
    rescue IOError => e
      Rails.logger.error("Unable to write EAD xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.backtrace}")
    rescue Git::FailedError => e
      Rails.logger.error("Unable to commit EAD xml for finding aid with ArchivesSpace ID to git: #{aspace_id}. Reason: #{e.message}")
    end
  end
end
