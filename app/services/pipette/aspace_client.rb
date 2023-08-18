# frozen_string_literal: true

require 'archivesspace/client'

module Pipette
  module AspaceClient
    def self.client(use_default_repo: true)
      client = ArchivesSpace::Client.new(client_config).login
      client.repository(2) if use_default_repo
      client
    end

    def self.client_config
      ArchivesSpace::Configuration.new({
                                         base_uri: ENV['ASPACE_URL'],
                                         base_repo: '',
                                         username: ENV['ASPACE_USER'],
                                         password: ENV['ASPACE_PASSWORD'],
                                         page_size: 50,
                                         throttle: 0,
                                         verify_ssl: false,
                                         timeout: 120
                                       })
    end

    private_class_method :client_config
  end
end
