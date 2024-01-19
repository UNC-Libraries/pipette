# frozen_string_literal: true

module Pipette
  class ProcessFindingAidsController < ApplicationController
    def process_all_ead
      force = params[:force] || false
      ead_ids = Pipette::AspaceClient.client.get('resources', { query: { all_ids: true } }).parsed
      ead_ids.each do |ead_id|
        ProcessEadXmlJob.perform_later(ead_id, force)
      end

      flash[:notice] = "All collections sent for indexing (#{ead_ids.length} collections)"
      redirect_to job_status_index_path
    end

    def process_selected_ead
      aspace_ids = params[:aspace_id].split(',')
      force = params[:force] || false
      aspace_ids.each do |ead_id|
        next if ead_id.strip.to_i.zero? # Returns 0 if not an integer

        ProcessEadXmlJob.perform_later(ead_id, force)
      end

      num_of_collections = aspace_ids.length
      flash[:notice] = "#{num_of_collections} #{'collection'.pluralize(num_of_collections)} sent for indexing"
      redirect_to job_status_index_path
    end

    def delete_ead
      aspace_id = params[:delete_aspace_id]
      return if aspace_id.to_i.zero? # Returns 0 if not an integer

      DeleteEadXmlJob.perform_later(aspace_id)

      flash[:notice] = "#{aspace_id} deleted from ArCHy"
      redirect_to job_status_index_path
    end
  end
end
