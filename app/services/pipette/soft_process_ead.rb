# frozen_string_literal: true

module Pipette
  class SoftProcessEad
    def delete(collection_id:)
      record_for_status_info = {
        collection_id: collection_id,
        collection_title: resource_record['title']
      }
    end

    def index

    end
  end
end
