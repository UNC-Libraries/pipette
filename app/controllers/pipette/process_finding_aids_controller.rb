module Pipette
  class ProcessFindingAidsController < ApplicationController
    def process_all_ead
      ead_ids = Pipette::AspaceClient.client.get('resources', { query: { all_ids: true } }).parsed
      ead_ids.each do |ead_id|
        ProcessEadXmlJob.perform_later(ead_id)
      end

      flash[:notice] = "All ArchivesSpace resources sent for processing (#{ead_ids.length} resources)"
      redirect_to resources_path
    end

    def process_ead
      ProcessEadXmlJob.perform_later(resource_params)
      flash[:notice] = "All ArchivesSpace resources sent for processing resources)"
      redirect_to resources_path
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:resource).permit(:resource_id)
    end
  end
end