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

ActiveRecord::Schema.define(version: 2020_06_08_084941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocation_requests", force: :cascade do |t|
    t.integer "number_eligible"
    t.integer "number_eligible_with_hotspot_access"
    t.bigint "created_by_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_user_id"], name: "index_allocation_requests_on_created_by_user_id"
  end

  create_table "mobile_networks", force: :cascade do |t|
    t.string "brand"
    t.string "host_network"
    t.boolean "participating_in_scheme"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand"], name: "index_mobile_networks_on_brand", unique: true
    t.index ["host_network", "brand"], name: "index_mobile_networks_on_host_network_and_brand", unique: true
  end

  create_table "recipients", force: :cascade do |t|
    t.string "full_name"
    t.string "address"
    t.string "postcode"
    t.boolean "can_access_hotspot"
    t.boolean "is_account_holder"
    t.string "account_holder_name"
    t.string "device_phone_number"
    t.string "phone_network_name"
    t.boolean "privacy_statement_sent_to_family"
    t.boolean "understands_how_pii_will_be_used"
    t.bigint "created_by_user"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "mobile_network_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email_address"
    t.string "organisation"
    t.string "dfe_sign_in_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dfe_sign_in_id"], name: "index_users_on_dfe_sign_in_id"
    t.index ["email_address"], name: "index_users_on_email_address"
  end

end
