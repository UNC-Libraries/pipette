# frozen_string_literal: true

require 'pipette/errors'

module Pipette
  class ProcessEadXmlJob < ApplicationJob
    queue_as :index

    def perform(aspace_id)
      Rails.logger.info "Starting download of EAD for finding aid with ArchivesSpace ID: #{aspace_id}"
      Pipette::ProcessEad.new.process(aspace_id: aspace_id)
      Rails.logger.info "EAD written to file for finding aid with ArchivesSpace ID: #{aspace_id}"
    rescue Pipette::AspaceRequestError,
           Pipette::ClassificationError,
           Pipette::UnpublishedError => e
      Rails.logger.error("Unable to download and process EAD xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.message}")
    rescue IOError => e
      Rails.logger.error("Unable to write EAD xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.backtrace}")
    end
  end
end
