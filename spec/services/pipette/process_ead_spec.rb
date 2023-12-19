require 'rails_helper'


RSpec.describe Pipette::ProcessEad do
  fixtures :pipette_collecting_units

  subject(:instance) { described_class.new }
  let(:aspace_id) { 123 }
  let(:ead) { '<?xml version="1.0" encoding="utf-8"?><ead></ead>' }
  let(:resource_record) do
    {
      'publish' => true,
      'classifications' => [{ 'ref' => '/repositories/2/classifications/1' }],
      'title' => 'My title',
      'ead_id' => 123,
      'system_mtime' => '2022-07-19T14:17:11Z',
      'uri' => '/aspace/123',
      'slug' => ''
    }
  end

  let(:resource_info) { instance_double Pipette::DownloadEad }
  let(:aspace_errors) { double Pipette::AspaceErrors }

  before do
    Rails.application.load_seed
    # No response errors
    allow(aspace_errors).to receive(:errors_check).and_return(nil)
    # Get the resource
    allow(Pipette::AspaceClient).to receive_message_chain(:client, :get)
      .with("resources/#{aspace_id}").and_return(resource_record.to_json)
    # Get the classification slug of the resource
    allow(Pipette::AspaceClient).to receive_message_chain(:client, :get)
      .with('/classifications/1').and_return({ slug: 'shc' }.to_json)
    # Get resource XML
    allow(Pipette::AspaceClient).to receive_message_chain(:client, :get)
      .with("resource_descriptions/#{aspace_id}.xml",
            { query: { ead3: false, include_daos: true,
                       include_unpublished: false, numbered_cs: true,
                       print_pdf: false, repo_id: 2 }, timeout: 1200 })
      .and_return(instance_double(HTTParty::Response, body: ead))
  end

  describe 'With new EAD' do
    it 'creates a new EAD record' do
      expect(Pipette::Resource.all.length).to eq(0)
      instance.process(aspace_id: aspace_id, is_deletion: false)
      expect(Pipette::Resource.all.length).to eq(1)
      expect(Pipette::Resource.first.resource_name).to eq('My title')
    end
  end

  describe 'With deleting an existing EAD' do
    it 'deletes an existing EAD record' do
      instance.process(aspace_id: aspace_id, is_deletion: false)
      expect(Pipette::Resource.all.length).to eq(1)
      instance.process(aspace_id: aspace_id, is_deletion: true)
      expect(Pipette::Resource.all.length).to eq(0)
    end
  end
end
