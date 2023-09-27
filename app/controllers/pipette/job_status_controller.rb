# frozen_string_literal: true

# Heavily borrowed from https://github.com/kenaniah/sidekiq-status/blob/v3.0.3/lib/sidekiq-status.rb
module Pipette
  class JobStatusController < ApplicationController
    def index
      jids = redis_adapter do |conn|
        conn.scan(match: 'sidekiq:status:*', count: 100).map do |key|
          key.split(':').last
        end.uniq
      end

      @job_statuses = []

      jids.each do |jid|
        status = Sidekiq::Status::get_all jid
        next if !status || status.count < 2

        status['collection_title'] = field_value(status['collection_title'])
        status['collection_id'] = field_value(status['collection_id'])
        status['collecting unit'] = field_value(status['collecting_unit'])
        status['worker'] = job_type(status['worker'])
        @job_statuses << status
      end

      @job_statuses.sort! { |y, x| (x['update_time'] <=> y['update_time']) || 1 }
    end

    def status_data
      jids = redis_adapter do |conn|
        conn.scan(match: 'sidekiq:status:*', count: 100).map do |key|
          key.split(':').last
        end.uniq
      end

      @job_statuses = []

      jids.each do |jid|
        status = Sidekiq::Status::get_all jid
        next if !status || status.count < 2

        status['collection_title'] = field_value(status['collection_title'])
        status['collection_id'] = field_value(status['collection_id'])
        status['collecting unit'] = field_value(status['collecting_unit'])
        status['worker'] = job_type(status['worker'])
        @job_statuses << status
      end

      @job_statuses.sort! { |y, x| (x['update_time'] <=> y['update_time']) || 1 }

      respond_to do |format|
        format.json { render json: @job_statuses }
      end
    end

    def field_value(value)
      return '' if value.blank?

      value
    end

    def job_type(job_type)
      return 'XML downloaded' if job_type.include? 'ProcessEadXmlJob'
      return 'Collection indexed' if job_type.include? 'IndexFindingAidJob'
      return 'PDF generated' if job_type.include? 'PdfGenerationJob'
      return 'Collection deleted' if job_type.include? 'DeleteEadXmlJob'

      'Unknown action'
    end

    # Methods pulled from sidekiq-status
    # https://github.com/kenaniah/sidekiq-status/blob/v3.0.3/lib/sidekiq-status.rb
    def wrap_redis_connection(conn)
      conn.is_a?(Pipette::RedisAdapter) ? conn : Pipette::RedisAdapter.new(conn)
    end

    def redis_adapter
      Sidekiq.redis { |conn| yield wrap_redis_connection(conn) }
    end
  end
end
