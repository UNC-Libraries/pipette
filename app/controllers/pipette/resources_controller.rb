module Pipette
  class ResourcesController < ApplicationController
    # GET /resources
    def index
      @resources = Resource.all
    end
  end
end
