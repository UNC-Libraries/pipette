# frozen_string_literal: true

module Pipette
  class ProcessAllEad
    include Pipette::AspaceHelper

    def process_all(index_since = 'half-hour')
      ead_ids = get_aspace_ids(index_since)
      if ead_ids.empty?
        puts "No ArchivesSpace collections were updated within the last #{index_since}. Nothing indexed into Arclight."
        return
      end

      ead_ids.each do |ead_id|
        ProcessEadXmlJob.perform_later(ead_id, true)
      end

      puts "#{ead_ids.length} collections sent for indexing."
    end
  end
end
