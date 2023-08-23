# frozen_string_literal: true

require 'pipette/errors'
require 'pipette'

module Pipette
  class ProcessEadXmlJob < ApplicationJob
    queue_as :aspace

    def perform(aspace_id)
      Rails.logger.info "Starting download of EAD for finding aid with ArchivesSpace ID: #{aspace_id}"
      ProcessEad.new.process(aspace_id: aspace_id)
      Rails.logger.info "EAD written to file for finding aid with ArchivesSpace ID: #{aspace_id}"
    rescue AspaceRequestError,
           ClassificationError,
           UnpublishedError => e
      Rails.logger.error("Unable to download and process EAD xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.message}")
    rescue MultiXml::ParseError
      Rails.logger.error("Unable to read xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.backtrace}")
    rescue IOError => e
      Rails.logger.error("Unable to write EAD xml for finding aid with ArchivesSpace ID: #{aspace_id}. Reason: #{e.backtrace}")
    rescue Git::FailedError => e
      Rails.logger.error("Unable to commit EAD xml for finding aid with ArchivesSpace ID to git: #{aspace_id}. Reason: #{e.message}")
    end
  end
end
