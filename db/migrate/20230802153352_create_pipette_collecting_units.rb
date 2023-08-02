class CreatePipetteCollectingUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :pipette_collecting_units do |t|
      t.string :collecting_unit

      t.timestamps
    end
  end
end
