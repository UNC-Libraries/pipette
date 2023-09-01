# frozen_string_literal: true

module Pipette
  class JobStatusController < ApplicationController
    def index
      statuses = connection.scan(0, match: 'sidekiq:status:*', count: 100)
      jids = statuses.last.map { |b| b.to_s.split(':').last }

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

    def connection
      Sidekiq.redis { |c| c }
    end

    def field_value(value)
      return '' if value.blank?

      value
    end

    def job_type(job_type)
      return 'XML downloaded' if job_type.include? 'ProcessEadXmlJob'
      return 'Collection indexed' if job_type.include? 'IndexFindingAidJob'
      return 'PDF generated' if job_type.include? 'PdfGenerationJob'
      return 'Collection deleted' if job_type.include? 'DeleteFindingAidJob'

      'Unknown action'
    end
  end
end
