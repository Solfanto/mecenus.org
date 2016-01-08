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

ActiveRecord::Schema.define(version: 20160108165637) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  add_index "admin_users", ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true, using: :btree

  create_table "donation_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.date     "date"
    t.float    "amount",                   default: 0.0
    t.string   "currency"
    t.float    "balance",                  default: 0.0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "processed_at"
    t.integer  "expected_donations_count", default: 0
    t.integer  "received_donations_count", default: 0
    t.datetime "aggregated_at"
    t.string   "stripe_transfer_id"
    t.string   "state"
  end

  create_table "donations", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "anonymous",              default: false
    t.integer  "project_id"
    t.float    "amount",                 default: 0.0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "enabled",                default: true
    t.string   "recurrence_type",        default: "monthly"
    t.integer  "processing_day",         default: 1
    t.string   "stripe_plan_id"
    t.string   "stripe_subscription_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "donation_id"
    t.integer  "donation_record_id"
    t.float    "amount",             default: 0.0
    t.string   "currency",           default: "USD"
    t.datetime "processed_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "state"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name"
    t.string   "title"
    t.text     "content"
    t.datetime "published_at"
    t.string   "permalink"
  end

  create_table "project_followships", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.boolean  "receive_notifications"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "project_memberships", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "title"
    t.string   "summary"
    t.text     "description"
    t.string   "url"
    t.string   "repo_url"
    t.float    "donation_amount_per_month", default: 0.0
    t.integer  "donations_count",           default: 0
    t.integer  "posts_count",               default: 0
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "published",                 default: false
    t.string   "latest_version"
    t.string   "readme_url"
    t.string   "changelog_url"
    t.string   "language"
    t.string   "license"
    t.datetime "latest_update_at"
    t.string   "country"
    t.datetime "closed_at"
    t.datetime "license_url"
    t.datetime "featured_from"
    t.datetime "featured_until"
    t.boolean  "verified",                  default: false
    t.datetime "verified_at"
    t.integer  "verified_by_id"
    t.integer  "processing_day",            default: 1
    t.string   "currency",                  default: "USD"
  end

  add_index "projects", ["verified_by_id"], name: "index_projects_on_verified_by_id", using: :btree

  create_table "stripe_events", force: :cascade do |t|
    t.string   "event_id"
    t.string   "object_type"
    t.string   "object_id"
    t.string   "object_description"
    t.text     "json"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "display_name"
    t.string   "twitter_username"
    t.string   "facebook_username"
    t.text     "bio"
    t.string   "location"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "email",                  default: "",  null: false
    t.string   "encrypted_password",     default: "",  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "stripe_account_id"
    t.string   "country"
    t.string   "currency"
    t.integer  "created_projects_count", default: 0
    t.datetime "deleted_at"
    t.string   "stripe_customer_id"
    t.float    "balance",                default: 0.0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
