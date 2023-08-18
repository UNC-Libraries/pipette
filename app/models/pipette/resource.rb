module Pipette
  class Resource < ApplicationRecord
    belongs_to :collecting_unit, foreign_key: :pipette_collecting_unit_id
  end
end
