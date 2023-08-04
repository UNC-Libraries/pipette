module Pipette
  class Resource < ApplicationRecord
    belongs_to :collecting_units
  end
end
