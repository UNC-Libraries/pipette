# frozen_string_literal: true

module Pipette
  class ProcessFindingAidsController < ApplicationController
    include Pipette::AspaceHelper

    def process_all_ead
      ead_ids = get_aspace_ids(params[:index_since])
      if ead_ids.empty?
        redirect_to job_status_index_path, notice: "No collections were updated within the specified time frame (#{params[:index_since]})."
        return
      end

      ead_ids.each do |ead_id|
        ProcessEadXmlJob.perform_later(ead_id, true)
      end

      flash_text = if params[:index_since] == 'all'
                     "All collections sent for indexing (#{ead_ids.length} collections)"
                   else
                     "#{ead_ids.length} collections sent for indexing"
                   end

      redirect_to job_status_index_path, notice: flash_text
    end

    def process_selected_ead
      aspace_ids = params[:aspace_id].split(',')
      aspace_ids.each do |ead_id|
        next if ead_id.strip.to_i.zero? # Returns 0 if not an integer

        ProcessEadXmlJob.perform_later(ead_id, should_force_indexing(params[:force]))
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

    private

    def should_force_indexing(param)
      return false if param.nil?

      ['true', true].include?(param)
    end
  end
end
