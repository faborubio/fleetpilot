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

ActiveRecord::Schema[8.1].define(version: 2026_06_11_225655) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.bigint "driver_id", null: false
    t.date "ended_on"
    t.date "started_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["account_id"], name: "index_assignments_on_account_id"
    t.index ["driver_id", "started_on"], name: "index_assignments_on_driver_id_and_started_on"
    t.index ["driver_id"], name: "index_assignments_on_driver_id"
    t.index ["vehicle_id", "started_on"], name: "index_assignments_on_vehicle_id_and_started_on"
    t.index ["vehicle_id"], name: "index_assignments_on_vehicle_id"
  end

  create_table "drivers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.date "license_expires_on"
    t.string "license_number"
    t.string "name", null: false
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_drivers_on_account_id_and_status"
    t.index ["account_id"], name: "index_drivers_on_account_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "vehicles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.integer "fuel_type"
    t.string "license_plate"
    t.string "make"
    t.string "model"
    t.integer "odometer", default: 0, null: false
    t.integer "purchase_price_cents"
    t.date "purchased_on"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "vin", limit: 17, null: false
    t.integer "year"
    t.index ["account_id", "status"], name: "index_vehicles_on_account_id_and_status"
    t.index ["account_id", "vin"], name: "index_vehicles_on_account_id_and_vin", unique: true
    t.index ["account_id"], name: "index_vehicles_on_account_id"
  end

  add_foreign_key "assignments", "accounts"
  add_foreign_key "assignments", "drivers"
  add_foreign_key "assignments", "vehicles"
  add_foreign_key "drivers", "accounts"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "accounts"
  add_foreign_key "vehicles", "accounts"
end
