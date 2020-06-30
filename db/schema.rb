# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_04_071047) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocation_requests", force: :cascade do |t|
    t.integer "number_eligible"
    t.integer "number_eligible_with_hotspot_access"
    t.bigint "created_by_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "responsible_body_id", null: false
    t.index ["created_by_user_id"], name: "index_allocation_requests_on_created_by_user_id"
    t.index ["responsible_body_id"], name: "index_allocation_requests_on_responsible_body_id"
  end

  create_table "bt_wifi_vouchers", force: :cascade do |t|
    t.string "username", null: false
    t.string "password", null: false
    t.integer "distributed_to_responsible_body_id"
    t.datetime "distributed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "extra_mobile_data_requests", force: :cascade do |t|
    t.string "account_holder_name"
    t.string "device_phone_number"
    t.bigint "created_by_user"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "mobile_network_id"
    t.string "status", null: false
    t.integer "created_by_user_id"
    t.boolean "agrees_with_privacy_statement"
    t.index ["mobile_network_id", "status", "created_at"], name: "index_emdr_on_mobile_network_id_and_status_and_created_at"
    t.index ["status"], name: "index_extra_mobile_data_requests_on_status"
  end

  create_table "mobile_networks", force: :cascade do |t|
    t.string "brand"
    t.string "host_network"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "participation_in_pilot"
    t.index ["brand"], name: "index_mobile_networks_on_brand", unique: true
    t.index ["host_network", "brand"], name: "index_mobile_networks_on_host_network_and_brand", unique: true
    t.index ["participation_in_pilot", "brand"], name: "index_mobile_networks_on_participation_in_pilot_and_brand"
  end

  create_table "responsible_bodies", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "organisation_type", null: false
    t.string "local_authority_official_name"
    t.string "local_authority_eng"
    t.string "companies_house_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email_address"
    t.string "organisation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sign_in_token"
    t.integer "mobile_network_id"
    t.datetime "sign_in_token_expires_at"
    t.datetime "approved_at"
    t.bigint "responsible_body_id"
    t.index ["approved_at"], name: "index_users_on_approved_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["mobile_network_id"], name: "index_users_on_mobile_network_id"
    t.index ["responsible_body_id"], name: "index_users_on_responsible_body_id"
    t.index ["sign_in_token"], name: "index_users_on_sign_in_token", unique: true
  end

  add_foreign_key "bt_wifi_vouchers", "responsible_bodies", column: "distributed_to_responsible_body_id"
end
