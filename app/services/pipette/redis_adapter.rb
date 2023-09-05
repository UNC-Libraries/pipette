# frozen_string_literal: true

# Pulled directly from https://github.com/kenaniah/sidekiq-status/blob/v3.0.3/lib/sidekiq-status/redis_adapter.rb
# It won't load via 'require' so it ended up here
# @TODO Check for updates when upgrading sidekiq and sidekiq-status upgrade
module Pipette
  class RedisAdapter
    def initialize(client)
      @client = client
    end

    def scan(**options, &block)
      @client.scan_each(**options, &block)
    end

    def schedule_batch(key, options)
      @client.zrangebyscore key, options[:start], options[:end], limit: [options[:offset], options[:limit]]
    end

    def method_missing(method, *args)
      @client.send(method, *args)
    end
  end
end
