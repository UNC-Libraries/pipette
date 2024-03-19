# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_02_153359) do
  create_table "pipette_collecting_units", force: :cascade do |t|
    t.string "collecting_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pipette_resources", force: :cascade do |t|
    t.integer "pipette_collecting_unit_id"
    t.integer "resource_uri"
    t.string "resource_name"
    t.string "resource_identifier"
    t.datetime "last_updated_on_aspace"
    t.datetime "last_indexed_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pipette_collecting_unit_id"], name: "index_pipette_resources_on_pipette_collecting_unit_id"
  end

  add_foreign_key "pipette_resources", "pipette_collecting_units"
end
