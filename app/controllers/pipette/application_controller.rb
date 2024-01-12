module Pipette
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :is_admin?

    def is_admin?
      redirect_to('/') unless current_user.admin?
    end
  end
end
