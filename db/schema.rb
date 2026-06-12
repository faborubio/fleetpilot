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

ActiveRecord::Schema[8.1].define(version: 2026_06_12_031732) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alerts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "alertable_id", null: false
    t.string "alertable_type", null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.date "due_on"
    t.string "message", null: false
    t.integer "severity", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_alerts_on_account_id_and_status"
    t.index ["account_id"], name: "index_alerts_on_account_id"
    t.index ["alertable_type", "alertable_id", "category"], name: "index_alerts_on_source_and_category"
    t.index ["alertable_type", "alertable_id"], name: "index_alerts_on_alertable"
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

  create_table "maintenance_schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "interval_miles"
    t.integer "interval_months"
    t.integer "last_performed_odometer"
    t.date "last_performed_on"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["account_id"], name: "index_maintenance_schedules_on_account_id"
    t.index ["vehicle_id", "category"], name: "index_maintenance_schedules_on_vehicle_id_and_category", unique: true
    t.index ["vehicle_id"], name: "index_maintenance_schedules_on_vehicle_id"
  end

  create_table "renewals", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.date "expires_on", null: false
    t.integer "kind", default: 0, null: false
    t.string "notes"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["account_id"], name: "index_renewals_on_account_id"
    t.index ["expires_on"], name: "index_renewals_on_expires_on"
    t.index ["vehicle_id", "kind"], name: "index_renewals_on_vehicle_id_and_kind", unique: true
    t.index ["vehicle_id"], name: "index_renewals_on_vehicle_id"
  end

  create_table "service_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "category", default: 0, null: false
    t.integer "cost_cents"
    t.datetime "created_at", null: false
    t.text "notes"
    t.integer "odometer"
    t.date "performed_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.string "vendor"
    t.index ["account_id"], name: "index_service_records_on_account_id"
    t.index ["vehicle_id", "performed_on"], name: "index_service_records_on_vehicle_id_and_performed_on"
    t.index ["vehicle_id"], name: "index_service_records_on_vehicle_id"
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
    t.boolean "notify_by_email", default: true, null: false
    t.boolean "notify_by_sms", default: false, null: false
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

  add_foreign_key "alerts", "accounts"
  add_foreign_key "assignments", "accounts"
  add_foreign_key "assignments", "drivers"
  add_foreign_key "assignments", "vehicles"
  add_foreign_key "drivers", "accounts"
  add_foreign_key "maintenance_schedules", "accounts"
  add_foreign_key "maintenance_schedules", "vehicles"
  add_foreign_key "renewals", "accounts"
  add_foreign_key "renewals", "vehicles"
  add_foreign_key "service_records", "accounts"
  add_foreign_key "service_records", "vehicles"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "accounts"
  add_foreign_key "vehicles", "accounts"
end
