# frozen_string_literal: true

module Pipette
  class CollectingUnit < ApplicationRecord
    has_many :resources
  end
end
