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

ActiveRecord::Schema.define(version: 2020_08_14_163708) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "status", null: false
    t.string "token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "name"], name: "index_api_tokens_on_user_id_and_name", unique: true
    t.index ["user_id", "token"], name: "index_api_tokens_on_user_id_and_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "bt_wifi_voucher_allocations", force: :cascade do |t|
    t.integer "responsible_body_id", null: false
    t.integer "amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bt_wifi_vouchers", force: :cascade do |t|
    t.string "username", null: false
    t.string "password", null: false
    t.integer "responsible_body_id"
    t.datetime "distributed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "extra_mobile_data_requests", force: :cascade do |t|
    t.string "account_holder_name"
    t.string "device_phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "mobile_network_id"
    t.string "status", null: false
    t.integer "created_by_user_id"
    t.boolean "agrees_with_privacy_statement"
    t.string "problem"
    t.bigint "responsible_body_id"
    t.string "contract_type"
    t.index ["mobile_network_id", "status", "created_at"], name: "index_emdr_on_mobile_network_id_and_status_and_created_at"
    t.index ["responsible_body_id"], name: "index_extra_mobile_data_requests_on_responsible_body_id"
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

  create_table "school_device_allocations", force: :cascade do |t|
    t.bigint "school_id"
    t.string "device_type", null: false
    t.integer "allocation", default: 0
    t.integer "devices_ordered", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "last_updated_by_user_id"
    t.bigint "created_by_user_id"
    t.index ["created_by_user_id"], name: "index_school_device_allocations_on_created_by_user_id"
    t.index ["last_updated_by_user_id"], name: "index_school_device_allocations_on_last_updated_by_user_id"
    t.index ["school_id"], name: "index_school_device_allocations_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.integer "urn", null: false
    t.string "name", null: false
    t.string "computacenter_reference"
    t.bigint "responsible_body_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_schools_on_name"
    t.index ["responsible_body_id"], name: "index_schools_on_responsible_body_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sign_in_token"
    t.integer "mobile_network_id"
    t.datetime "sign_in_token_expires_at"
    t.datetime "approved_at"
    t.bigint "responsible_body_id"
    t.integer "sign_in_count", default: 0
    t.datetime "last_signed_in_at"
    t.index ["approved_at"], name: "index_users_on_approved_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["mobile_network_id"], name: "index_users_on_mobile_network_id"
    t.index ["responsible_body_id"], name: "index_users_on_responsible_body_id"
    t.index ["sign_in_token"], name: "index_users_on_sign_in_token", unique: true
  end

  add_foreign_key "bt_wifi_voucher_allocations", "responsible_bodies"
  add_foreign_key "bt_wifi_vouchers", "responsible_bodies"
  add_foreign_key "extra_mobile_data_requests", "responsible_bodies"
  add_foreign_key "school_device_allocations", "schools"
  add_foreign_key "schools", "responsible_bodies"
end
