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

ActiveRecord::Schema[7.0].define(version: 2022_05_15_204513) do
  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "area_type", null: false
    t.boolean "supply_center", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_areas_on_name", unique: true
  end

  create_table "borders", force: :cascade do |t|
    t.integer "area_id", null: false
    t.integer "neighbor_id", null: false
    t.integer "coast_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "neighbor_id", "coast_id"], name: "index_borders_on_area_id_and_neighbor_id_and_coast_id", unique: true
    t.index ["area_id"], name: "index_borders_on_area_id"
    t.index ["neighbor_id"], name: "index_borders_on_neighbor_id"
  end

  create_table "coasts", force: :cascade do |t|
    t.integer "area_id", null: false
    t.string "direction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "direction"], name: "index_coasts_on_area_id_and_direction", unique: true
    t.index ["area_id"], name: "index_coasts_on_area_id"
  end

  add_foreign_key "borders", "areas"
  add_foreign_key "borders", "areas", column: "neighbor_id"
  add_foreign_key "borders", "coasts"
  add_foreign_key "coasts", "areas"
end
