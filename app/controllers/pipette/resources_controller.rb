module Pipette
  class ResourcesController < ApplicationController
    # GET /resources
    def index
      @resources = Resource.all
    end

    def new; end

    def update_all_resources(only_since_last_update: true)
      resource_ids = Pipette::AspaceClient.client.get('resources', { query: { all_ids: true } }).parsed
      resource_ids.each do |resource_id|
        ProcessEadXmlJob.perform_later(resource_id)
      end
    end

    def update_resource
      resource_ids = Pipette::AspaceClient.client.get('resources', { query: { all_ids: true } }).parsed
      resource_ids.each do |resource_id|
        ProcessEadXmlJob.perform_later(resource_id)
      end
    end
  end
end
