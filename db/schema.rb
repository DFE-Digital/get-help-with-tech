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

ActiveRecord::Schema.define(version: 2020_09_24_142403) do

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

  create_table "computacenter_user_changes", force: :cascade do |t|
    t.integer "user_id"
    t.text "first_name"
    t.text "last_name"
    t.text "email_address"
    t.text "telephone"
    t.text "responsible_body"
    t.text "responsible_body_urn"
    t.text "cc_sold_to_number"
    t.text "school"
    t.text "school_urn"
    t.text "cc_ship_to_number"
    t.datetime "updated_at_timestamp"
    t.integer "type_of_update"
    t.text "original_email_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "original_first_name"
    t.text "original_last_name"
    t.text "original_telephone"
    t.text "original_responsible_body"
    t.text "original_responsible_body_urn"
    t.text "original_cc_sold_to_number"
    t.text "original_school"
    t.text "original_school_urn"
    t.text "original_cc_ship_to_number"
    t.index ["updated_at_timestamp"], name: "index_computacenter_user_changes_on_updated_at_timestamp"
    t.index ["user_id"], name: "index_computacenter_user_changes_on_user_id"
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
    t.integer "responsible_body_id", null: false
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

  create_table "preorder_information", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "who_will_order_devices", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", null: false
    t.bigint "school_contact_id"
    t.string "will_need_chromebooks"
    t.string "school_or_rb_domain"
    t.string "recovery_email_address"
    t.datetime "school_contacted_at"
    t.index ["school_contact_id"], name: "index_preorder_information_on_school_contact_id"
    t.index ["school_id"], name: "index_preorder_information_on_school_id"
    t.index ["status"], name: "index_preorder_information_on_status"
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
    t.boolean "in_devices_pilot", default: false
    t.boolean "in_connectivity_pilot", default: false
    t.string "who_will_order_devices"
    t.string "computacenter_reference"
    t.string "gias_group_uid"
    t.string "gias_id"
    t.bigint "key_contact_id"
    t.index ["computacenter_reference"], name: "index_responsible_bodies_on_computacenter_reference"
    t.index ["gias_group_uid"], name: "index_responsible_bodies_on_gias_group_uid", unique: true
    t.index ["gias_id"], name: "index_responsible_bodies_on_gias_id", unique: true
    t.index ["key_contact_id"], name: "index_responsible_bodies_on_key_contact_id"
  end

  create_table "school_contacts", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.string "role"
    t.string "title"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id", "email_address"], name: "index_school_contacts_on_school_id_and_email_address", unique: true
    t.index ["school_id"], name: "index_school_contacts_on_school_id"
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
    t.integer "cap", default: 0, null: false
    t.datetime "cap_update_request_timestamp"
    t.string "cap_update_request_payload_id"
    t.index ["cap"], name: "index_school_device_allocations_on_cap"
    t.index ["cap_update_request_payload_id"], name: "ix_allocations_cap_update_payload_id"
    t.index ["cap_update_request_timestamp"], name: "ix_allocations_cap_update_timestamp"
    t.index ["created_by_user_id"], name: "index_school_device_allocations_on_created_by_user_id"
    t.index ["last_updated_by_user_id"], name: "index_school_device_allocations_on_last_updated_by_user_id"
    t.index ["school_id"], name: "index_school_device_allocations_on_school_id"
  end

  create_table "school_welcome_wizards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "step", default: "privacy", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "user_orders_devices"
    t.boolean "first_school_user"
    t.bigint "invited_user_id"
    t.boolean "show_chromebooks"
    t.index ["invited_user_id"], name: "index_school_welcome_wizards_on_invited_user_id"
    t.index ["user_id"], name: "index_school_welcome_wizards_on_user_id"
  end

  create_table "schools", force: :cascade do |t|
    t.integer "urn", null: false
    t.string "name", null: false
    t.string "computacenter_reference"
    t.bigint "responsible_body_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "town"
    t.string "county"
    t.string "postcode"
    t.string "phase"
    t.string "establishment_type"
    t.string "phone_number"
    t.string "order_state", default: "cannot_order", null: false
    t.index ["name"], name: "index_schools_on_name"
    t.index ["responsible_body_id"], name: "index_schools_on_responsible_body_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_schools", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "school_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id", "user_id"], name: "index_user_schools_on_school_id_and_user_id", unique: true
    t.index ["school_id"], name: "index_user_schools_on_school_id"
    t.index ["user_id", "school_id"], name: "index_user_schools_on_user_id_and_school_id", unique: true
    t.index ["user_id"], name: "index_user_schools_on_user_id"
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
    t.string "telephone"
    t.boolean "is_support", default: false, null: false
    t.boolean "is_computacenter", default: false, null: false
    t.datetime "privacy_notice_seen_at"
    t.boolean "orders_devices"
    t.bigint "legacy_school_id"
    t.datetime "techsource_account_confirmed_at"
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email_address_unique", unique: true
    t.index ["approved_at"], name: "index_users_on_approved_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["legacy_school_id", "full_name"], name: "index_users_on_legacy_school_id_and_full_name"
    t.index ["legacy_school_id"], name: "index_users_on_legacy_school_id"
    t.index ["mobile_network_id"], name: "index_users_on_mobile_network_id"
    t.index ["responsible_body_id"], name: "index_users_on_responsible_body_id"
    t.index ["sign_in_token"], name: "index_users_on_sign_in_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "bt_wifi_voucher_allocations", "responsible_bodies"
  add_foreign_key "bt_wifi_vouchers", "responsible_bodies"
  add_foreign_key "extra_mobile_data_requests", "responsible_bodies"
  add_foreign_key "preorder_information", "school_contacts"
  add_foreign_key "responsible_bodies", "users", column: "key_contact_id"
  add_foreign_key "school_device_allocations", "schools"
  add_foreign_key "school_welcome_wizards", "users", column: "invited_user_id"
  add_foreign_key "schools", "responsible_bodies"
end
