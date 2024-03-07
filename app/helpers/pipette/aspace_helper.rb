# frozen_string_literal: true

module Pipette
  module AspaceHelper
    def get_aspace_ids(index_since)
      query_vars = {
        all_ids: true
      }
      query_vars[:modified_since] = time_offset(index_since) unless index_since.nil? || index_since == 'all'

      Pipette::AspaceClient.client.get('resources', { query: query_vars }).parsed
    end

    # Time periods are in seconds
    def time_offset(index_since)
      offset = index_since.downcase

      case offset
      when 'half-hour'
        updated_since(1800)
      when 'hour'
        updated_since(3600)
      when 'half-day'
        updated_since(43_200)
      when 'full-day'
        updated_since(86_400)
      else # one week
        updated_since(604_800)
      end
    end

    # Get the number of seconds since a time offset
    def updated_since(period)
      (Time.parse(Time.now.to_s).to_i - period).to_s
    end
  end
end
