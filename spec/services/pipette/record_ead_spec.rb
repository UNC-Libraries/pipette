# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Pipette::RecordEad do
  fixtures :pipette_collecting_units

  subject(:instance) { described_class.new }
  let(:resource) do
    {
      'publish' => true,
      'classifications' => [{ 'ref' => '/repositories/2/classifications/2' }],
      'title' => 'My title',
      'ead_id' => 1234,
      'system_mtime' => '2022-07-19T14:17:11Z',
      'uri' => '/aspace/8933'
    }
  end

  describe 'With new EAD' do
    it 'creates a new EAD record' do
      expect(Pipette::Resource.all.length).to eq(0)
      instance.update_database(1, resource, false)
      expect(Pipette::Resource.all.length).to eq(1)
      expect(Pipette::Resource.first.resource_name).to eq('My title')
    end
  end

  describe 'With updated EAD' do
    let(:updated_resource) do
      {
        'publish' => true,
        'classifications' => [{ 'ref' => '/repositories/2/classifications/2' }],
        'title' => 'My updated title',
        'ead_id' => 1234,
        'system_mtime' => '2022-07-21T14:17:11Z',
        'uri' => '/aspace/8933'
      }
    end

    it 'updates an existing EAD record' do
      expect(Pipette::Resource.all.length).to eq(0)
      instance.update_database(1, resource, false)
      expect(Pipette::Resource.all.length).to eq(1)

      instance.update_database(1, updated_resource, false)
      expect(Pipette::Resource.first.resource_name).to eq('My updated title')
      expect(Pipette::Resource.all.length).to eq(1)
    end
  end

  describe 'With deleted EAD' do
    it 'deletes an EAD record' do
      expect(Pipette::Resource.all.length).to eq(0)
      instance.update_database(1, resource, false) # Add record
      expect(Pipette::Resource.all.length).to eq(1)

      instance.update_database(1, resource, true) # Delete record
      expect(Pipette::Resource.all.length).to eq(0)
    end
  end
end
