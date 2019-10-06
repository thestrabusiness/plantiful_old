# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_05_235130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "check_ins", force: :cascade do |t|
    t.bigint "plant_id", null: false
    t.string "notes"
    t.boolean "watered", default: false, null: false
    t.boolean "fertilized", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "performed_by_id", null: false
    t.index ["fertilized"], name: "index_check_ins_on_fertilized"
    t.index ["performed_by_id"], name: "index_check_ins_on_performed_by_id"
    t.index ["plant_id"], name: "index_check_ins_on_plant_id"
    t.index ["watered", "fertilized"], name: "index_check_ins_on_watered_and_fertilized"
    t.index ["watered"], name: "index_check_ins_on_watered"
  end

  create_table "gardens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
  end

  create_table "plants", force: :cascade do |t|
    t.string "name"
    t.string "botanical_name"
    t.integer "check_frequency_scalar", default: 3, null: false
    t.string "check_frequency_unit", default: "days", null: false
    t.bigint "added_by_id", null: false
    t.bigint "garden_id", null: false
    t.index ["added_by_id"], name: "index_plants_on_added_by_id"
    t.index ["garden_id"], name: "index_plants_on_garden_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.bigint "garden_id", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["garden_id"], name: "index_users_on_garden_id"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "check_ins", "plants"
  add_foreign_key "check_ins", "users", column: "performed_by_id"
  add_foreign_key "plants", "users", column: "added_by_id"
  add_foreign_key "users", "gardens"
end
