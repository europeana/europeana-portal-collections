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

ActiveRecord::Schema.define(version: 20150910110528) do

  create_table "banners", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "state",      limit: 4,     default: 0
  end

  add_index "banners", ["key"], name: "index_banners_on_key", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,   null: false
    t.string   "user_type",     limit: 255
    t.string   "document_id",   limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type", limit: 255
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "browse_entries", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.text     "query",           limit: 65535
    t.integer  "landing_page_id", limit: 4
    t.integer  "media_object_id", limit: 4
    t.integer  "position",        limit: 4
    t.text     "settings",        limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "browse_entries", ["landing_page_id"], name: "index_browse_entries_on_landing_page_id", using: :btree
  add_index "browse_entries", ["media_object_id"], name: "index_browse_entries_on_media_object_id", using: :btree

  create_table "channels", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.text     "api_params", limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "state",      limit: 4
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "hero_images", force: :cascade do |t|
    t.integer  "media_object_id", limit: 4
    t.string   "license",         limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "settings",        limit: 65535
  end

  add_index "hero_images", ["media_object_id"], name: "fk_rails_491dc63aec", using: :btree

  create_table "landing_pages", force: :cascade do |t|
    t.integer  "channel_id",    limit: 4
    t.integer  "hero_image_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "state",         limit: 4, default: 0
  end

  add_index "landing_pages", ["channel_id"], name: "fk_rails_8b1a2f89f6", using: :btree
  add_index "landing_pages", ["hero_image_id"], name: "fk_rails_a59254ed81", using: :btree

  create_table "links", force: :cascade do |t|
    t.string   "text",            limit: 255
    t.text     "url",             limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "type",            limit: 255
    t.text     "settings",        limit: 65535
    t.integer  "linkable_id",     limit: 4
    t.string   "linkable_type",   limit: 255
    t.integer  "position",        limit: 4
    t.integer  "media_object_id", limit: 4
  end

  add_index "links", ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id", using: :btree
  add_index "links", ["media_object_id"], name: "index_links_on_media_object_id", using: :btree

  create_table "media_objects", force: :cascade do |t|
    t.text     "source_url",        limit: 65535
    t.string   "source_url_hash",   limit: 32
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
    t.string   "file_fingerprint",  limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "media_objects", ["source_url_hash"], name: "index_media_objects_on_source_url_hash", using: :btree

  create_table "searches", force: :cascade do |t|
    t.text     "query_params", limit: 65535
    t.integer  "user_id",      limit: 4
    t.string   "user_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                              default: false
    t.string   "role",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id",       limit: 4
    t.string  "foreign_key_name", limit: 255, null: false
    t.integer "foreign_key_id",   limit: 4
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,        null: false
    t.integer  "item_id",        limit: 4,          null: false
    t.string   "event",          limit: 255,        null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.text     "object_changes", limit: 4294967295
    t.integer  "transaction_id", limit: 4
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

end
