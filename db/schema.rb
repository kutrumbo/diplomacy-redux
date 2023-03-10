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

ActiveRecord::Schema[7.0].define(version: 2023_02_22_061646) do
  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "area_type", null: false
    t.boolean "supply_center", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nationality"
    t.index ["name"], name: "index_areas_on_name", unique: true
  end

  create_table "borders", force: :cascade do |t|
    t.integer "area_id", null: false
    t.integer "neighbor_id", null: false
    t.integer "coast_id"
    t.boolean "coastal", default: false, null: false
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

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer "position_id", null: false
    t.string "order_type"
    t.integer "area_from_id"
    t.integer "area_to_id"
    t.integer "coast_from_id"
    t.integer "coast_to_id"
    t.string "resolution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confirmed", default: false, null: false
    t.index ["area_from_id"], name: "index_orders_on_area_from_id"
    t.index ["area_to_id"], name: "index_orders_on_area_to_id"
    t.index ["coast_from_id"], name: "index_orders_on_coast_from_id"
    t.index ["coast_to_id"], name: "index_orders_on_coast_to_id"
    t.index ["position_id"], name: "index_orders_on_position_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "nationality", null: false
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "nationality"
    t.string "unit_type"
    t.integer "area_id", null: false
    t.integer "coast_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "turn_id", null: false
    t.boolean "dislodged", default: false, null: false
    t.integer "player_id", null: false
    t.index ["area_id"], name: "index_positions_on_area_id"
    t.index ["coast_id"], name: "index_positions_on_coast_id"
    t.index ["player_id"], name: "index_positions_on_player_id"
    t.index ["turn_id"], name: "index_positions_on_turn_id"
  end

  create_table "turns", force: :cascade do |t|
    t.string "type", null: false
    t.integer "number", null: false
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  add_foreign_key "borders", "areas"
  add_foreign_key "borders", "areas", column: "neighbor_id"
  add_foreign_key "borders", "coasts"
  add_foreign_key "coasts", "areas"
  add_foreign_key "orders", "areas", column: "area_from_id"
  add_foreign_key "orders", "areas", column: "area_to_id"
  add_foreign_key "orders", "coasts", column: "coast_from_id"
  add_foreign_key "orders", "coasts", column: "coast_to_id"
  add_foreign_key "orders", "positions"
  add_foreign_key "players", "games"
  add_foreign_key "positions", "areas"
  add_foreign_key "positions", "coasts"
  add_foreign_key "positions", "players"
  add_foreign_key "positions", "turns"
  add_foreign_key "turns", "games"
end
