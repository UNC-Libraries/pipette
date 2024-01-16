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
      'slug' => 'shc',
      'user_mtime' => '2022-01-12T14:19:19Z'
    }
  end

  before do
    Rails.application.load_seed
    # No response errors
    allow(Pipette::AspaceErrors).to receive_message_chain(:new, :errors_check).with(resource_record: anything, aspace_id: 123).and_return(nil)
    # Get the classification slug of the resource
    allow(Pipette::AspaceClient).to receive_message_chain(:client, :get, :parsed)
      .with('/classifications/1').with(no_args).and_return({ slug: 'shc' })
    # Get the resource
    allow(Pipette::AspaceClient).to receive_message_chain(:client, :get, :parsed)
                                      .with("resources/#{aspace_id}").with(no_args).and_return(resource_record)
    # Get resource XML
    allow(Pipette::AspaceClient).to receive_message_chain(:client, :get, :body)
      .with("resource_descriptions/#{aspace_id}.xml")
      .with({ query: { ead3: false, include_daos: true,
                       include_unpublished: false, numbered_cs: true,
                       print_pdf: false, repo_id: 2 }, timeout: 1200 })
      .with(no_args)
      .and_return(ead)
  end

  describe 'With new EAD' do
    it 'creates a new EAD record' do
      expect(Pipette::Resource.all.length).to eq(0)
      instance.process(aspace_id: aspace_id, is_deletion: false, force: false)
      expect(Pipette::Resource.all.length).to eq(1)
      expect(Pipette::Resource.first.resource_name).to eq('My title')
    end
  end

  describe 'With an existing EAD' do
    it 'deletes an existing EAD record' do
      instance.process(aspace_id: aspace_id, is_deletion: false, force: false)
      expect(Pipette::Resource.all.length).to eq(1)
      instance.process(aspace_id: aspace_id, is_deletion: true, force: false)
      expect(Pipette::Resource.all.length).to eq(0)
    end

    context "When updating an EAD record" do
      let(:update_record) { spy("Pipette::RecordEad.new") }

      it 'updates an existing EAD record if the force option is set' do
        # Create the record
        new_record_time = record_created
        # Update the record
        instance.process(aspace_id: aspace_id, is_deletion: false, force: true)
        expect(Pipette::Resource.first['updated_at']).to be > new_record_time
      end

      it 'does not update an existing EAD record if the force option is not set' do
        # Create the record
        new_record_time = record_created
        # Update the record
        instance.process(aspace_id: aspace_id, is_deletion: false, force: false)
        expect(Pipette::Resource.first['updated_at']).to eq new_record_time
      end

      def record_created
        instance.process(aspace_id: aspace_id, is_deletion: false, force: false)
        expect(Pipette::Resource.all.length).to eq(1)
        Pipette::Resource.first['updated_at']
      end
    end
  end
end
