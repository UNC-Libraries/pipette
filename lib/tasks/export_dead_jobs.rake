# frozen_string_literal: true

require 'csv'
require 'sidekiq/api'
require 'active_support/core_ext/date_time/calculations'

namespace :pipette do
  desc 'Exports a list of dead Sidekiq jobs. Pass in an integer to retrieve dead jobs for the past (n) days through today'
  desc 'Defaults to returning today\'s failed jobs, if no arguments are provided'
  desc 'On VM: bundle exec rake pipette:export_dead_jobs[7]'
  desc 'On server: scl enable rh-ruby30 -- sudo LD_LIBRARY_PATH=/opt/rh/rh-ruby30/root/usr/local/lib64:/opt/rh/rh-ruby30/root/usr/lib64 bundle exec rake pipette:export_dead_jobs[7] RAILS_ENV=production'
  task :export_dead_jobs, [:failed_since] => :environment do |_t, args|
    ds = Sidekiq::DeadSet.new

    CSV.open('/tmp/archy_dead_jobs_report.csv', 'w') do |csv|
      csv << ['Job Type', 'Args', 'Error']
      ds.each do |job|
        if (args[:failed_since].nil? && job.at.today?) ||
           (job.at >= args[:failed_since].to_i.day.ago && job.at <= DateTime.now.end_of_day)
          csv << [job.display_class, job.display_args.join('|'), job['error_message']]
        end
      end
    end
  end
end
