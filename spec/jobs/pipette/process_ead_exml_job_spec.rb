require 'rails_helper'

RSpec.describe Pipette::ProcessEadXmlJob, type: :job do
  include ActiveJob::TestHelper

  let(:aspace_id) { 1234 }
  let(:src_path) { "fixtures/ead_downloads/ncc/07713.xml" }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { described_class.perform_later(aspace_id) }.to have_enqueued_job(described_class).with(aspace_id).on_queue('aspace')
  end

  describe 'aspace request errors' do
    before do
      allow(Pipette::AspaceErrors.new).to receive(:errors_check)
                                            .with({ resource_record: { 'errors' => 'bad error' }, aspace_id: 12 })
                                            .and_raise(Pipette::AspaceRequestError)
    end

    it 'catches aspace request errors' do
      expect { described_class.perform_later(aspace_id) }.not_to raise_error
    end
  end

  describe 'classification errors' do
    before do
      allow(Pipette::AspaceErrors.new).to receive(:errors_check)
                                            .with({ resource_record: { 'errors' => 'bad error' }, aspace_id: 12 })
                                            .and_raise(Pipette::AspaceRequestError)
    end

    it 'catches classification errors' do
      expect { described_class.perform_later(aspace_id) }.not_to raise_error
    end
  end

  describe 'unpublished errors' do
    before do
      allow(File).to receive(:open).with(src_path, "r:UTF-8:UTF-8").and_raise(IOError)
    end

    it 'catches unpublished errors' do
      expect { described_class.perform_later(aspace_id) }.not_to raise_error
    end
  end

  describe 'file not found errors' do
    before do
      allow(File).to receive(:open).with(src_path, "r:UTF-8:UTF-8").and_raise(IOError)
    end

    it 'catches file not found errors' do
      expect { described_class.perform_later(aspace_id) }.not_to raise_error
    end
  end

  describe 'xml parsing errors' do
    before do
      allow(Nokogiri::XML).to receive(:parse).with('<ead></ead>').and_raise(MultiXml::ParseError)
    end

    it 'catches xml errors' do
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
