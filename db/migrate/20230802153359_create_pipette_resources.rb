class CreatePipetteResources < ActiveRecord::Migration[7.0]
  def change
    create_table :pipette_resources do |t|
      t.belongs_to :pipette_collecting_unit, foreign_key: true
      t.integer :resource_uri
      t.string :resource_name
      t.string :resource_identifier
      t.datetime :last_updated_on_aspace
      t.datetime :last_indexed_on

      t.timestamps
    end
  end
end
