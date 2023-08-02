module Pipette
  class Resource < ApplicationRecord
    has_many :collecting_units
  end
end
