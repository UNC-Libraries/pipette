class CreatePipetteResources < ActiveRecord::Migration[7.0]
  def change
    create_table :pipette_resources do |t|
      t.integer :resource_uri
      t.string :resource_name
      t.string :resource_identifier
      t.datetime :last_updated_on_aspace
      t.datetime :last_indexed_on

      t.timestamps
    end

    add_foreign_key :pipette_resources, :collecting_units
  end
end
