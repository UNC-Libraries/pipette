module Pipette
  module ApplicationHelper
    # Convert dates to timestamps and compare
    def needs_indexing?(arclight_date, aspace_date)
      return true if arclight_date.nil?

      arclight_date.to_datetime.to_i < aspace_date.to_datetime.to_i
    end
  end
end
