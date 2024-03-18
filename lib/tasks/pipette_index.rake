# frozen_string_literal: true

namespace :pipette do
  desc 'Indexes EADS into Arclight that have been updated on ArchivesSpace within the given timeframe'
  desc 'Valid options for index_since: all, half-hour, hour, half-day, full-day, week'
  desc 'On VM: bundle exec rake pipette:export_dead_jobs["hour"]'
  desc 'On server: scl enable rh-ruby30 -- sudo LD_LIBRARY_PATH=/opt/rh/rh-ruby30/root/usr/local/lib64:/opt/rh/rh-ruby30/root/usr/lib64 bundle exec rake pipette:export_dead_jobs["hour"] RAILS_ENV=production'
  task :index_updated_ead, [:index_since] => :environment do |_t, args|
    Pipette::ProcessAllEad.new.process_all(args[:index_since])
  end
end
