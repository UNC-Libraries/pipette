# frozen_string_literal: true

require 'archivesspace/client'

module Pipette
  module AspaceClient
    def self.client
      client = ArchivesSpace::Client.new(client_config).login
      client.repository(2)
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
                                         timeout: 300
                                       })
    end

    private_class_method :client_config
  end
end
