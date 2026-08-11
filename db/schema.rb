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

ActiveRecord::Schema[8.0].define(version: 2026_08_09_141613) do
  create_table "Passwords", force: :cascade do |t|
    t.string "LoginType"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "isActive"
  end

  create_table "custom_sessions", force: :cascade do |t|
    t.string "cookie"
    t.string "IP"
    t.integer "login_count"
    t.datetime "expire_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mfa_tokens", force: :cascade do |t|
    t.string "token"
    t.boolean "isActive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
