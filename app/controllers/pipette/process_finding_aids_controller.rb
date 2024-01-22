# frozen_string_literal: true

module Pipette
  class ProcessFindingAidsController < ApplicationController
    def process_all_ead
      ead_ids = get_aspace_ids(params[:index_since])
      if ead_ids.empty?
        redirect_to job_status_index_path, notice: "No collections were updated within the specified time frame (#{params[:index_since]})."
        return
      end

      force = params[:force] || false
      ead_ids.each do |ead_id|
        ProcessEadXmlJob.perform_later(ead_id, force)
      end

      flash_text = if params[:index_since] == 'all'
                     "All collections sent for indexing (#{ead_ids.length} collections)"
                   else
                     "#{ead_ids.length} sent for indexing"
                   end

      redirect_to job_status_index_path, notice: flash_text
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

    private

    def get_aspace_ids(index_since)
      query_vars = {
        all_ids: true
      }
      query_vars[:modified_since] = time_offset unless index_since.nil?

      Pipette::AspaceClient.client.get('resources', { query: query_vars }).parsed
    end

    # Time periods are in seconds
    def time_offset
      offset = params[:index_since].downcase
      return nil if offset == 'all'

      case offset
      when 'hour'
        updated_since(3600)
      when 'half-day'
        updated_since(43_200)
      when 'full-day'
        updated_since(86_400)
      else # one week
        updated_since(604_800)
      end
    end

    # Get the number of seconds since a time offset
    def updated_since(period)
      (Time.parse(Time.now.to_s).to_i - period).to_s
    end
  end
end
