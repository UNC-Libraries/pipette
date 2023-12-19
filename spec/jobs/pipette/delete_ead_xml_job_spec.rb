require 'rails_helper'

RSpec.describe Pipette::DeleteEadXmlJob, type: :job do
  include ActiveJob::TestHelper

  let(:aspace_id) { 1234 }
  let(:src_path) { "fixtures/ead_downloads/ncc/07713.xml" }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { described_class.perform_later(aspace_id) }.to have_enqueued_job(described_class).with(aspace_id).on_queue('delete')
  end

  describe 'unable to delete file errors' do
    before do
      allow(File).to receive(:open).with(src_path, "r:UTF-8:UTF-8").and_raise(Errno::ENOENT)
    end

    it 'catches file not found errors' do
      expect { described_class.perform_later(aspace_id) }.not_to raise_error
    end
  end


  describe 'git errors' do
    before do
      allow(Git).to receive(:open).with(ENV['FINDING_AID_DATA'].to_s).and_raise(Git::FailedError)
    end

    it 'catches git errors' do
      expect { described_class.perform_later(aspace_id) }.not_to raise_error
    end
  end
end
