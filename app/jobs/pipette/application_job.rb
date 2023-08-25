module Pipette
  class ApplicationJob < ActiveJob::Base
    include Sidekiq::Status::Worker
  end
end
