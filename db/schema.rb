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

ActiveRecord::Schema.define(version: 2022_02_08_122126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocation_batch_jobs", force: :cascade do |t|
    t.text "batch_id", null: false
    t.string "urn"
    t.integer "ukprn"
    t.integer "allocation_delta", null: false
    t.text "order_state"
    t.boolean "send_notification", default: true, null: false
    t.boolean "sent_notification", default: false, null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "applied_allocation_delta"
    t.index "abs((allocation_delta - applied_allocation_delta)) DESC, urn, ukprn", name: "idx_delta_mismatch_urn_ukprn"
    t.index ["batch_id"], name: "index_allocation_batch_jobs_on_batch_id"
  end

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

  create_table "assets", force: :cascade do |t|
    t.string "tag"
    t.string "serial_number", null: false
    t.string "model"
    t.string "department"
    t.string "department_id"
    t.string "department_sold_to_id"
    t.string "location"
    t.string "location_id"
    t.string "location_cc_ship_to_account"
    t.string "encrypted_bios_password"
    t.string "encrypted_admin_password"
    t.string "encrypted_hardware_hash"
    t.datetime "sys_created_at"
    t.datetime "first_viewed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_sold_to_id"], name: "index_assets_on_department_sold_to_id"
    t.index ["location_cc_ship_to_account"], name: "index_assets_on_location_cc_ship_to_account"
    t.index ["serial_number"], name: "index_assets_on_serial_number"
  end

  create_table "batch_job_log_entries", force: :cascade do |t|
    t.string "record_id"
    t.string "record_class"
    t.string "job_name"
    t.string "run_id"
    t.string "status"
    t.string "message"
    t.string "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["job_name", "created_at"], name: "index_batch_job_log_entries_on_job_name_and_created_at"
    t.index ["run_id", "created_at"], name: "index_batch_job_log_entries_on_run_id_and_created_at"
    t.index ["run_id", "record_class", "record_id"], name: "ix_btle_run_record"
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

  create_table "cap_changes", force: :cascade do |t|
    t.string "category"
    t.integer "prev_cap", default: 0, null: false
    t.integer "new_cap", default: 0, null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "school_id"
    t.string "device_type", default: "laptop", null: false
    t.index ["category"], name: "index_cap_changes_on_category"
  end

  create_table "cap_update_calls", force: :cascade do |t|
    t.text "request_body"
    t.text "response_body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "failure", default: false
    t.bigint "school_id"
    t.string "device_type", default: "laptop", null: false
  end

  create_table "computacenter_cap_usage_update_payloads", force: :cascade do |t|
    t.string "payload_id"
    t.string "payload_xml"
    t.datetime "payload_timestamp"
    t.integer "records_count"
    t.integer "succeeded_count"
    t.integer "failed_count"
    t.string "status"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payload_id"], name: "index_computacenter_cap_usage_update_payloads_on_payload_id"
  end

  create_table "computacenter_devices_ordered_updates", force: :cascade do |t|
    t.string "cap_type"
    t.string "ship_to"
    t.integer "cap_amount"
    t.integer "cap_used"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cap_usage_update_payload_id"
    t.index ["cap_usage_update_payload_id"], name: "index_devices_ordered_updates_on_cap_usage_update_payload_id"
    t.index ["ship_to"], name: "index_computacenter_devices_ordered_updates_on_ship_to"
  end

  create_table "computacenter_orders", force: :cascade do |t|
    t.string "raw_customer_order_number"
    t.string "raw_delivery_date"
    t.string "raw_despatch_date"
    t.string "raw_is_return"
    t.string "raw_manufacturer_name"
    t.string "raw_material_description"
    t.string "raw_material_number"
    t.string "raw_order_completed"
    t.string "raw_order_date"
    t.string "raw_order_days_to_delivery"
    t.string "raw_order_days_to_despatch"
    t.string "raw_persona"
    t.string "raw_persona_description"
    t.string "raw_quantity_completed"
    t.string "raw_quantity_ordered"
    t.string "raw_quantity_outstanding"
    t.string "raw_sales_order_number"
    t.string "raw_school_urn"
    t.string "raw_ship_to_account_no"
    t.string "raw_ship_to_customer"
    t.string "raw_sold_to_account_no"
    t.string "raw_sold_to_customer"
    t.string "raw_urn_cc"
    t.string "raw_school_urn_flag"
    t.date "delivery_date"
    t.date "despatch_date"
    t.date "order_date"
    t.boolean "is_return"
    t.boolean "order_completed"
    t.integer "school_urn"
    t.integer "order_days_to_delivery"
    t.integer "order_days_to_despatch"
    t.integer "quantity_completed"
    t.integer "quantity_ordered"
    t.integer "quantity_outstanding"
    t.string "provision_urn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provision_urn"], name: "index_computacenter_orders_on_provision_urn"
    t.index ["raw_school_urn_flag"], name: "index_computacenter_orders_on_raw_school_urn_flag"
    t.index ["raw_ship_to_account_no"], name: "index_computacenter_orders_on_raw_ship_to_account_no"
    t.index ["raw_sold_to_account_no"], name: "index_computacenter_orders_on_raw_sold_to_account_no"
    t.index ["school_urn"], name: "index_computacenter_orders_on_school_urn"
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
    t.datetime "cc_import_api_timestamp"
    t.string "cc_import_api_transaction_id"
    t.boolean "cc_rb_user"
    t.boolean "original_cc_rb_user"
    t.index ["cc_import_api_timestamp"], name: "ix_cc_user_changes_timestamp"
    t.index ["cc_import_api_transaction_id"], name: "ix_cc_user_changes_cc_tx_id"
    t.index ["updated_at_timestamp"], name: "index_computacenter_user_changes_on_updated_at_timestamp"
    t.index ["user_id"], name: "index_computacenter_user_changes_on_user_id"
  end

  create_table "data_update_records", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "staged_at"
    t.datetime "updated_records_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_data_update_records_on_name", unique: true
  end

  create_table "donated_device_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "device_types", default: [], array: true
    t.integer "units"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "schools", default: [], array: true
    t.bigint "responsible_body_id"
    t.string "status", default: "incomplete", null: false
    t.string "opt_in_choice"
    t.datetime "completed_at"
    t.index ["completed_at"], name: "index_donated_device_requests_on_completed_at"
    t.index ["responsible_body_id"], name: "index_donated_device_requests_on_responsible_body_id"
    t.index ["user_id"], name: "index_donated_device_requests_on_user_id"
  end

  create_table "email_audits", force: :cascade do |t|
    t.string "message_type", null: false
    t.string "template"
    t.string "email_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "school_id"
    t.text "govuk_notify_id"
    t.text "govuk_notify_status"
    t.index ["govuk_notify_id"], name: "index_email_audits_on_govuk_notify_id"
    t.index ["message_type"], name: "index_email_audits_on_message_type"
    t.index ["school_id"], name: "index_email_audits_on_school_id"
    t.index ["user_id"], name: "index_email_audits_on_user_id"
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
    t.integer "responsible_body_id"
    t.string "contract_type"
    t.bigint "school_id"
    t.string "normalised_name"
    t.string "hashed_account_holder_name"
    t.string "hashed_normalised_name"
    t.string "hashed_device_phone_number"
    t.index ["hashed_account_holder_name"], name: "index_extra_mobile_data_requests_on_hashed_account_holder_name"
    t.index ["hashed_device_phone_number"], name: "index_extra_mobile_data_requests_on_hashed_device_phone_number"
    t.index ["hashed_normalised_name"], name: "index_extra_mobile_data_requests_on_hashed_normalised_name"
    t.index ["mobile_network_id", "status", "created_at"], name: "index_emdr_on_mobile_network_id_and_status_and_created_at"
    t.index ["normalised_name"], name: "index_extra_mobile_data_requests_on_normalised_name"
    t.index ["responsible_body_id"], name: "index_extra_mobile_data_requests_on_responsible_body_id"
    t.index ["school_id"], name: "index_extra_mobile_data_requests_on_school_id"
    t.index ["status"], name: "index_extra_mobile_data_requests_on_status"
  end

  create_table "mobile_networks", force: :cascade do |t|
    t.string "brand"
    t.string "host_network"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "participation_in_pilot"
    t.boolean "excluded_fe_network", default: false, null: false
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

  create_table "remaining_device_counts", force: :cascade do |t|
    t.datetime "date_of_count", null: false
    t.integer "remaining_from_devolved_schools", null: false
    t.integer "remaining_from_managed_schools", null: false
    t.integer "total_remaining", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date_of_count"], name: "index_remaining_device_counts_on_date_of_count"
  end

  create_table "reportable_events", force: :cascade do |t|
    t.string "event_name"
    t.string "record_type"
    t.bigint "record_id"
    t.datetime "event_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_name", "event_time", "record_type", "record_id"], name: "ix_re_name_time_type_id"
    t.index ["record_type", "record_id", "event_name", "event_time"], name: "ix_re_type_id_name_time"
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
    t.string "default_who_will_order_devices_for_schools"
    t.string "computacenter_reference"
    t.string "gias_group_uid"
    t.string "gias_id"
    t.bigint "key_contact_id"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "town"
    t.string "county"
    t.string "postcode"
    t.string "status", default: "open", null: false
    t.boolean "vcap", default: false
    t.string "computacenter_change", default: "none", null: false
    t.boolean "new_fe_wave", default: false
    t.integer "laptop_allocation", default: 0, null: false
    t.integer "laptop_cap", default: 0, null: false
    t.integer "laptops_ordered", default: 0, null: false
    t.integer "router_allocation", default: 0, null: false
    t.integer "router_cap", default: 0, null: false
    t.integer "routers_ordered", default: 0, null: false
    t.index ["computacenter_change"], name: "index_responsible_bodies_on_computacenter_change"
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

  create_table "school_links", force: :cascade do |t|
    t.bigint "school_id"
    t.text "link_type", null: false
    t.integer "urn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_school_links_on_school_id"
  end

  create_table "school_welcome_wizards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "step", default: "allocation", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "user_orders_devices"
    t.boolean "first_school_user"
    t.bigint "invited_user_id"
    t.boolean "show_chromebooks"
    t.bigint "school_id"
    t.index ["invited_user_id"], name: "index_school_welcome_wizards_on_invited_user_id"
    t.index ["school_id"], name: "index_school_welcome_wizards_on_school_id"
    t.index ["user_id", "school_id"], name: "index_school_welcome_wizards_on_user_id_and_school_id", unique: true
    t.index ["user_id"], name: "index_school_welcome_wizards_on_user_id"
  end

  create_table "schools", force: :cascade do |t|
    t.integer "urn"
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
    t.string "status", default: "open", null: false
    t.string "computacenter_change", default: "none", null: false
    t.boolean "increased_allocations_feature_flag", default: false
    t.boolean "increased_sixth_form_feature_flag", default: false
    t.boolean "increased_fe_feature_flag", default: false
    t.string "type", default: "CompulsorySchool", null: false
    t.integer "ukprn"
    t.text "fe_type"
    t.boolean "hide_mno", default: false
    t.datetime "opted_out_of_comms_at"
    t.string "provision_urn"
    t.string "provision_type"
    t.string "preorder_status"
    t.bigint "school_contact_id"
    t.string "will_need_chromebooks"
    t.string "school_or_rb_domain"
    t.string "recovery_email_address"
    t.datetime "school_contacted_at"
    t.string "who_will_order_devices"
    t.integer "raw_laptop_allocation", default: 0, null: false
    t.integer "raw_laptops_ordered", default: 0, null: false
    t.datetime "laptop_cap_update_request_timestamp"
    t.string "laptop_cap_update_request_payload_id"
    t.integer "raw_router_allocation", default: 0, null: false
    t.integer "raw_routers_ordered", default: 0, null: false
    t.datetime "router_cap_update_request_timestamp"
    t.string "router_cap_update_request_payload_id"
    t.integer "circumstances_laptops", default: 0, null: false
    t.integer "circumstances_routers", default: 0, null: false
    t.integer "over_order_reclaimed_laptops", default: 0, null: false
    t.integer "over_order_reclaimed_routers", default: 0, null: false
    t.index ["computacenter_change"], name: "index_schools_on_computacenter_change"
    t.index ["name"], name: "index_schools_on_name"
    t.index ["provision_urn"], name: "index_schools_on_provision_urn", unique: true
    t.index ["responsible_body_id"], name: "index_schools_on_responsible_body_id"
    t.index ["type", "id"], name: "index_schools_on_type_and_id"
    t.index ["type"], name: "index_schools_on_type"
    t.index ["ukprn"], name: "index_schools_on_ukprn", unique: true
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "expires_at"
  end

  create_table "staged_school_links", force: :cascade do |t|
    t.bigint "staged_school_id"
    t.integer "link_urn", null: false
    t.string "link_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["staged_school_id", "link_urn"], name: "index_staged_school_links_on_staged_school_id_and_link_urn", unique: true
    t.index ["staged_school_id"], name: "index_staged_school_links_on_staged_school_id"
  end

  create_table "staged_schools", force: :cascade do |t|
    t.integer "urn", null: false
    t.string "name", null: false
    t.string "responsible_body_name", null: false
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "town"
    t.string "county"
    t.string "postcode"
    t.string "phase", null: false
    t.string "establishment_type"
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_staged_schools_on_name"
    t.index ["status"], name: "index_staged_schools_on_status"
    t.index ["urn"], name: "index_staged_schools_on_urn"
  end

  create_table "staged_trusts", force: :cascade do |t|
    t.string "name", null: false
    t.string "organisation_type", null: false
    t.string "gias_group_uid", null: false
    t.string "companies_house_number"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "town"
    t.string "county"
    t.string "postcode"
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gias_group_uid"], name: "index_staged_trusts_on_gias_group_uid", unique: true
    t.index ["name"], name: "index_staged_trusts_on_name"
    t.index ["status"], name: "index_staged_trusts_on_status"
  end

  create_table "supplier_outages", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "user_id"
    t.text "session_id", null: false
    t.text "user_type"
    t.text "user_profile_path"
    t.text "full_name"
    t.text "email_address"
    t.text "telephone_number"
    t.text "school_name"
    t.text "school_unique_id"
    t.text "school_urn"
    t.text "academy_name"
    t.text "college_name"
    t.text "college_ukprn"
    t.text "local_authority_name"
    t.text "support_topics", default: [], array: true
    t.text "message"
    t.text "zendesk_ticket_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_support_tickets_on_session_id"
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
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
    t.bigint "responsible_body_id"
    t.integer "sign_in_count", default: 0
    t.datetime "last_signed_in_at"
    t.string "telephone"
    t.boolean "is_support", default: false, null: false
    t.boolean "is_computacenter", default: false, null: false
    t.datetime "privacy_notice_seen_at"
    t.boolean "orders_devices", default: false
    t.datetime "techsource_account_confirmed_at"
    t.datetime "deleted_at"
    t.text "role", default: "no", null: false
    t.boolean "rb_level_access", default: false, null: false
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email_address_unique", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
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
  add_foreign_key "computacenter_devices_ordered_updates", "computacenter_cap_usage_update_payloads", column: "cap_usage_update_payload_id"
  add_foreign_key "extra_mobile_data_requests", "responsible_bodies"
  add_foreign_key "extra_mobile_data_requests", "schools"
  add_foreign_key "preorder_information", "school_contacts"
  add_foreign_key "responsible_bodies", "users", column: "key_contact_id"
  add_foreign_key "school_welcome_wizards", "users", column: "invited_user_id"
  add_foreign_key "schools", "responsible_bodies"
  add_foreign_key "support_tickets", "users"
end
