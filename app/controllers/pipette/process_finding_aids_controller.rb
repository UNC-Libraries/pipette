# frozen_string_literal: true

module Pipette
  class ProcessFindingAidsController < ApplicationController
    def process_all_ead
      ead_ids = Pipette::AspaceClient.client.get('resources', { query: { all_ids: true } }).parsed
      #ead_ids.each do |ead_id|
        ProcessEadXmlJob.perform_later('03834')
      #end

      flash[:notice] = "All collections sent for indexing (#{ead_ids.length} collections)"
      redirect_to resources_path
    end

    def process_selected_ead
      aspace_ids = params[:aspace_id].split(',')
      aspace_ids.each do |ead_id|
        next if ead_id.to_i.zero? # Returns 0 if not an integer

        ProcessEadXmlJob.perform_later(ead_id)
      end

      flash[:notice] = "#{aspace_ids.length} collections sent for indexing"
      redirect_to resources_path
    end
  end
end
