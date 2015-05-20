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

ActiveRecord::Schema.define(version: 20150512161700) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,   null: false
    t.string   "user_type",     limit: 255
    t.string   "document_id",   limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type", limit: 255
  end

  add_index "bookmarks", ["document_type", "document_id"], name: "index_bookmarks_on_document_type_and_document_id", using: :btree
  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "refinery_images", force: :cascade do |t|
    t.string   "image_mime_type", limit: 255
    t.string   "image_name",      limit: 255
    t.integer  "image_size",      limit: 4
    t.integer  "image_width",     limit: 4
    t.integer  "image_height",    limit: 4
    t.string   "image_uid",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_title",     limit: 255
    t.string   "image_alt",       limit: 255
  end

  create_table "refinery_page_part_translations", force: :cascade do |t|
    t.integer  "refinery_page_part_id", limit: 4,     null: false
    t.string   "locale",                limit: 255,   null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "body",                  limit: 65535
  end

  add_index "refinery_page_part_translations", ["locale"], name: "index_refinery_page_part_translations_on_locale", using: :btree
  add_index "refinery_page_part_translations", ["refinery_page_part_id"], name: "index_refinery_page_part_translations_on_refinery_page_part_id", using: :btree

  create_table "refinery_page_parts", force: :cascade do |t|
    t.integer  "refinery_page_id", limit: 4
    t.string   "title",            limit: 255
    t.text     "body",             limit: 65535
    t.integer  "position",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refinery_page_parts", ["id"], name: "index_refinery_page_parts_on_id", using: :btree
  add_index "refinery_page_parts", ["refinery_page_id"], name: "index_refinery_page_parts_on_refinery_page_id", using: :btree

  create_table "refinery_page_translations", force: :cascade do |t|
    t.integer  "refinery_page_id", limit: 4,   null: false
    t.string   "locale",           limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "title",            limit: 255
    t.string   "custom_slug",      limit: 255
    t.string   "menu_title",       limit: 255
    t.string   "slug",             limit: 255
  end

  add_index "refinery_page_translations", ["locale"], name: "index_refinery_page_translations_on_locale", using: :btree
  add_index "refinery_page_translations", ["refinery_page_id"], name: "index_refinery_page_translations_on_refinery_page_id", using: :btree

  create_table "refinery_pages", force: :cascade do |t|
    t.integer  "parent_id",           limit: 4
    t.string   "path",                limit: 255
    t.string   "slug",                limit: 255
    t.string   "custom_slug",         limit: 255
    t.boolean  "show_in_menu",        limit: 1,   default: true
    t.string   "link_url",            limit: 255
    t.string   "menu_match",          limit: 255
    t.boolean  "deletable",           limit: 1,   default: true
    t.boolean  "draft",               limit: 1,   default: false
    t.boolean  "skip_to_first_child", limit: 1,   default: false
    t.integer  "lft",                 limit: 4
    t.integer  "rgt",                 limit: 4
    t.integer  "depth",               limit: 4
    t.string   "view_template",       limit: 255
    t.string   "layout_template",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refinery_pages", ["depth"], name: "index_refinery_pages_on_depth", using: :btree
  add_index "refinery_pages", ["id"], name: "index_refinery_pages_on_id", using: :btree
  add_index "refinery_pages", ["lft"], name: "index_refinery_pages_on_lft", using: :btree
  add_index "refinery_pages", ["parent_id"], name: "index_refinery_pages_on_parent_id", using: :btree
  add_index "refinery_pages", ["rgt"], name: "index_refinery_pages_on_rgt", using: :btree

  create_table "refinery_resources", force: :cascade do |t|
    t.string   "file_mime_type", limit: 255
    t.string   "file_name",      limit: 255
    t.integer  "file_size",      limit: 4
    t.string   "file_uid",       limit: 255
    t.string   "file_ext",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "refinery_roles", force: :cascade do |t|
    t.string "title", limit: 255
  end

  create_table "refinery_roles_users", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "refinery_roles_users", ["role_id", "user_id"], name: "index_refinery_roles_users_on_role_id_and_user_id", using: :btree
  add_index "refinery_roles_users", ["user_id", "role_id"], name: "index_refinery_roles_users_on_user_id_and_role_id", using: :btree

  create_table "refinery_user_plugins", force: :cascade do |t|
    t.integer "user_id",  limit: 4
    t.string  "name",     limit: 255
    t.integer "position", limit: 4
  end

  add_index "refinery_user_plugins", ["name"], name: "index_refinery_user_plugins_on_name", using: :btree
  add_index "refinery_user_plugins", ["user_id", "name"], name: "index_refinery_user_plugins_on_user_id_and_name", unique: true, using: :btree

  create_table "refinery_users", force: :cascade do |t|
    t.string   "username",               limit: 255, null: false
    t.string   "email",                  limit: 255, null: false
    t.string   "encrypted_password",     limit: 255, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "sign_in_count",          limit: 4
    t.datetime "remember_created_at"
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                   limit: 255
    t.string   "full_name",              limit: 255
  end

  add_index "refinery_users", ["id"], name: "index_refinery_users_on_id", using: :btree
  add_index "refinery_users", ["slug"], name: "index_refinery_users_on_slug", using: :btree

  create_table "searches", force: :cascade do |t|
    t.text     "query_params", limit: 65535
    t.integer  "user_id",      limit: 4
    t.string   "user_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "seo_meta", force: :cascade do |t|
    t.integer  "seo_meta_id",      limit: 4
    t.string   "seo_meta_type",    limit: 255
    t.string   "browser_title",    limit: 255
    t.text     "meta_description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "seo_meta", ["id"], name: "index_seo_meta_on_id", using: :btree
  add_index "seo_meta", ["seo_meta_id", "seo_meta_type"], name: "id_type_index_on_seo_meta", using: :btree

  create_table "spotlight_attachments", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "file",       limit: 255
    t.string   "uid",        limit: 255
    t.integer  "exhibit_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spotlight_blacklight_configurations", force: :cascade do |t|
    t.integer  "exhibit_id",                limit: 4
    t.text     "facet_fields",              limit: 65535
    t.text     "index_fields",              limit: 65535
    t.text     "search_fields",             limit: 65535
    t.text     "sort_fields",               limit: 65535
    t.text     "default_solr_params",       limit: 65535
    t.text     "show",                      limit: 65535
    t.text     "index",                     limit: 65535
    t.integer  "default_per_page",          limit: 4
    t.text     "per_page",                  limit: 65535
    t.text     "document_index_view_types", limit: 65535
    t.string   "thumbnail_size",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spotlight_contact_emails", force: :cascade do |t|
    t.integer  "exhibit_id",           limit: 4
    t.string   "email",                limit: 255, default: "", null: false
    t.string   "confirmation_token",   limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spotlight_contact_emails", ["confirmation_token"], name: "index_spotlight_contact_emails_on_confirmation_token", unique: true, using: :btree
  add_index "spotlight_contact_emails", ["email", "exhibit_id"], name: "index_spotlight_contact_emails_on_email_and_exhibit_id", unique: true, using: :btree

  create_table "spotlight_contacts", force: :cascade do |t|
    t.string   "slug",            limit: 255
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "title",           limit: 255
    t.string   "location",        limit: 255
    t.string   "telephone",       limit: 255
    t.boolean  "show_in_sidebar", limit: 1
    t.integer  "weight",          limit: 4,     default: 50
    t.integer  "exhibit_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contact_info",    limit: 65535
    t.string   "avatar",          limit: 255
    t.integer  "avatar_crop_x",   limit: 4
    t.integer  "avatar_crop_y",   limit: 4
    t.integer  "avatar_crop_w",   limit: 4
    t.integer  "avatar_crop_h",   limit: 4
  end

  add_index "spotlight_contacts", ["exhibit_id"], name: "index_spotlight_contacts_on_exhibit_id", using: :btree

  create_table "spotlight_custom_fields", force: :cascade do |t|
    t.integer  "exhibit_id",    limit: 4
    t.string   "slug",          limit: 255
    t.string   "field",         limit: 255
    t.text     "configuration", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "field_type",    limit: 255
  end

  create_table "spotlight_exhibits", force: :cascade do |t|
    t.boolean  "default",        limit: 1
    t.string   "title",          limit: 255,                  null: false
    t.string   "subtitle",       limit: 255
    t.string   "slug",           limit: 255
    t.text     "description",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "searchable",     limit: 1,     default: true
    t.string   "layout",         limit: 255
    t.boolean  "published",      limit: 1,     default: true
    t.datetime "published_at"
    t.string   "featured_image", limit: 255
    t.integer  "masthead_id",    limit: 4
    t.integer  "thumbnail_id",   limit: 4
  end

  add_index "spotlight_exhibits", ["default"], name: "index_spotlight_exhibits_on_default", unique: true, using: :btree
  add_index "spotlight_exhibits", ["slug"], name: "index_spotlight_exhibits_on_slug", unique: true, using: :btree

  create_table "spotlight_featured_images", force: :cascade do |t|
    t.string   "type",               limit: 255
    t.boolean  "display",            limit: 1
    t.string   "image",              limit: 255
    t.string   "source",             limit: 255
    t.string   "document_global_id", limit: 255
    t.integer  "image_crop_x",       limit: 4
    t.integer  "image_crop_y",       limit: 4
    t.integer  "image_crop_w",       limit: 4
    t.integer  "image_crop_h",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spotlight_locks", force: :cascade do |t|
    t.integer  "on_id",      limit: 4
    t.string   "on_type",    limit: 255
    t.integer  "by_id",      limit: 4
    t.string   "by_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spotlight_locks", ["on_id", "on_type"], name: "index_spotlight_locks_on_on_id_and_on_type", unique: true, using: :btree

  create_table "spotlight_main_navigations", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.integer  "weight",     limit: 4,   default: 20
    t.string   "nav_type",   limit: 255
    t.integer  "exhibit_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display",    limit: 1,   default: true
  end

  add_index "spotlight_main_navigations", ["exhibit_id"], name: "index_spotlight_main_navigations_on_exhibit_id", using: :btree

  create_table "spotlight_pages", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "type",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "scope",             limit: 255
    t.text     "content",           limit: 65535
    t.integer  "weight",            limit: 4,     default: 50
    t.boolean  "published",         limit: 1
    t.integer  "exhibit_id",        limit: 4
    t.integer  "created_by_id",     limit: 4
    t.integer  "last_edited_by_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_page_id",    limit: 4
    t.boolean  "display_sidebar",   limit: 1
    t.boolean  "display_title",     limit: 1
    t.integer  "thumbnail_id",      limit: 4
  end

  add_index "spotlight_pages", ["exhibit_id"], name: "index_spotlight_pages_on_exhibit_id", using: :btree
  add_index "spotlight_pages", ["parent_page_id"], name: "index_spotlight_pages_on_parent_page_id", using: :btree
  add_index "spotlight_pages", ["slug", "scope"], name: "index_spotlight_pages_on_slug_and_scope", unique: true, using: :btree

  create_table "spotlight_resources", force: :cascade do |t|
    t.integer  "exhibit_id", limit: 4
    t.string   "type",       limit: 255
    t.string   "url",        limit: 255
    t.text     "data",       limit: 65535
    t.datetime "indexed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spotlight_roles", force: :cascade do |t|
    t.integer "exhibit_id", limit: 4
    t.integer "user_id",    limit: 4
    t.string  "role",       limit: 255
  end

  add_index "spotlight_roles", ["exhibit_id", "user_id"], name: "index_spotlight_roles_on_exhibit_id_and_user_id", unique: true, using: :btree

  create_table "spotlight_searches", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "slug",              limit: 255
    t.string   "scope",             limit: 255
    t.text     "short_description", limit: 65535
    t.text     "long_description",  limit: 65535
    t.text     "query_params",      limit: 65535
    t.integer  "weight",            limit: 4
    t.boolean  "on_landing_page",   limit: 1
    t.integer  "exhibit_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "featured_item_id",  limit: 255
    t.integer  "masthead_id",       limit: 4
    t.integer  "thumbnail_id",      limit: 4
  end

  add_index "spotlight_searches", ["exhibit_id"], name: "index_spotlight_searches_on_exhibit_id", using: :btree
  add_index "spotlight_searches", ["slug", "scope"], name: "index_spotlight_searches_on_slug_and_scope", unique: true, using: :btree

  create_table "spotlight_solr_document_sidecars", force: :cascade do |t|
    t.integer  "exhibit_id",    limit: 4
    t.boolean  "public",        limit: 1,     default: true
    t.text     "data",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_id",   limit: 255
    t.string   "document_type", limit: 255
  end

  add_index "spotlight_solr_document_sidecars", ["exhibit_id"], name: "index_spotlight_solr_document_sidecars_on_exhibit_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.string   "taggable_id",   limit: 255
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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
    t.boolean  "guest",                  limit: 1,   default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
