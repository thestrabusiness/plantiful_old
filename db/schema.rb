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

ActiveRecord::Schema.define(version: 2019_08_30_124900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_ins", force: :cascade do |t|
    t.bigint "plant_id", null: false
    t.string "notes"
    t.boolean "watered", default: false, null: false
    t.boolean "fertilized", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fertilized"], name: "index_check_ins_on_fertilized"
    t.index ["plant_id"], name: "index_check_ins_on_plant_id"
    t.index ["watered", "fertilized"], name: "index_check_ins_on_watered_and_fertilized"
    t.index ["watered"], name: "index_check_ins_on_watered"
  end

  create_table "plants", force: :cascade do |t|
    t.string "name"
    t.string "botanical_name"
    t.bigint "user_id"
    t.integer "check_frequency_scalar", default: 3, null: false
    t.string "check_frequency_unit", default: "days", null: false
    t.index ["user_id"], name: "index_plants_on_user_id"
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
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "check_ins", "plants"
  add_foreign_key "plants", "users"
end
