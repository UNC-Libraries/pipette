# frozen_string_literal: true

namespace :pipette do
  desc 'Indexes EADS into Arclight that have been updated on ArchivesSpace within the given timeframe'
  desc 'Valid options for index_since: all, half-hour, hour, half-day, full-day, week'
  desc 'On VM: bundle exec rake pipette:index_updated_ead["hour"]'
  desc 'On server: source /opt/rh/rh-ruby30/enable; sudo -E LD_LIBRARY_PATH=${LD_LIBRARY_PATH} bundle exec rake pipette:index_updated_ead["hour"] RAILS_ENV=production'
  task :index_updated_ead, [:index_since] => :environment do |_t, args|
    Pipette::ProcessAllEad.new.process_all(args[:index_since])
  end
end
