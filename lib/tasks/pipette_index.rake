# frozen_string_literal: true

namespace :pipette do
  desc 'Indexes EADS into Arclight that have been updated on ArchivesSpace within the given timeframe'
  desc 'Valid options for index_since: all, half-hour, hour, half-day, full-day, week'
  task :index_updated_ead, [:index_since] => :environment do |_t, args|
    Pipette::ProcessAllEad.new.process_all(args[:index_since])
  end
end
