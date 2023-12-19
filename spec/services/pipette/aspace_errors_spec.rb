# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Pipette::AspaceErrors do
  subject(:instance) { described_class.new }
  let(:aspace_id) { 'aspace_1234' }

  describe 'With no errors' do
    let(:resource_record) do
      {
        'publish' => true,
        'classifications' => ['/my/classification'],
        'title' => 'My title',
        'ead_id' => 1234
      }
    end

    it 'does not throw an error' do
      expect(instance.errors_check(resource_record: resource_record, aspace_id: aspace_id)).to eq(nil)
    end
  end

  describe 'With an unpublished EAD' do
    let(:resource_record) do
      {
        'publish' => false,
        'classifications' => ['/my/classification'],
        'title' => 'My title',
        'ead_id' => 1234
      }
    end

    it 'throws a Pipette::UnpublishedError' do
      expect { instance.errors_check(resource_record: resource_record, aspace_id: aspace_id) }.to raise_error(Pipette::UnpublishedError)
    end
  end

  describe 'With no classifications' do
    let(:resource_record) do
      {
        'publish' => true,
        'classifications' => [],
        'title' => 'My title',
        'ead_id' => 1234
      }
    end

    it 'throws a Pipette::ClassificationError' do
      expect { instance.errors_check(resource_record: resource_record, aspace_id: aspace_id) }.to raise_error(Pipette::ClassificationError)
    end
  end

  describe 'With an aspace error' do
    let(:resource_record) do
      {
        'error' => 'Could not connect to aspace'
      }
    end

    it 'throws a Pipette::ClassificationError' do
      expect { instance.errors_check(resource_record: resource_record, aspace_id: aspace_id) }.to raise_error(Pipette::AspaceRequestError)
    end
  end
end
