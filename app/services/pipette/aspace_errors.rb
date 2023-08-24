# frozen_string_literal: true

require 'pipette/errors'

module Pipette
  class AspaceErrors
    def errors_check(resource_record:, aspace_id:)
      if resource_record.key?('error')
        message = format_error_msg(resource_record['error'])
        raise Pipette::AspaceRequestError, "Error processing record #{aspace_id} from Aspace. #{message}"
      elsif !resource_record['publish']
        raise Pipette::UnpublishedError, "#{resource_record['ead_id']}-#{resource_record['title']} is unpublished. Skipping downloading and indexing"
      elsif resource_record['classifications'].blank?
        raise Pipette::ClassificationError, "No classifications were found for EAD #{resource_record['ead_id']}-#{resource_record['title']}. Skipping downloading and indexing"
      end
    end

    private

    def format_error_msg(error_list)
      return error_list unless error_list.is_a?(Array)

      message = ''
      error_list.each do |value|
        message += "#{value.join('; ')}\n"
      end
      message
    end
  end
end
