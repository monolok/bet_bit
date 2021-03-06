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

ActiveRecord::Schema.define(version: 20170329151624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bets", force: :cascade do |t|
    t.decimal  "base_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal  "last_price"
    t.string   "status"
    t.string   "result"
  end

  create_table "gamblers", force: :cascade do |t|
    t.string   "bet_address"
    t.string   "client_address"
    t.integer  "bet_id"
    t.boolean  "status",         default: false
    t.boolean  "up",             default: false
    t.boolean  "down",           default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

end
