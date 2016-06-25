# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160624010258) do

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "price"
    t.string   "image_url"
    t.string   "item_code"
  end

  create_table "shelter_items", force: :cascade do |t|
    t.integer  "shelter_id", null: false
    t.integer  "item_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shelter_items", ["item_id"], name: "index_shelter_items_on_item_id"
  add_index "shelter_items", ["shelter_id"], name: "index_shelter_items_on_shelter_id"

  create_table "shelters", force: :cascade do |t|
    t.string   "shelter_name"
    t.string   "home_adress"
    t.string   "email"
    t.string   "password_digest"
    t.string   "phone"
    t.string   "representative_name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "shelters", ["email"], name: "index_shelters_on_email", unique: true

  create_table "user_items", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "shelter_item_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "user_items", ["shelter_item_id"], name: "index_user_items_on_shelter_item_id"
  add_index "user_items", ["user_id"], name: "index_user_items_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "user_name"
    t.string   "home_adress"
    t.string   "phone"
    t.string   "user_type"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
