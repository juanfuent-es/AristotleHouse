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

ActiveRecord::Schema[8.1].define(version: 2026_11_23_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.string "alt", default: "", null: false
    t.string "file", default: "", null: false
    t.string "published_file"
    t.integer "width", default: 0, null: false
    t.integer "height", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((title)::text)", name: "index_images_on_title", unique: true
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", null: false, comment: "project | static | web-lab"
    t.string "slug", null: false
    t.string "title", limit: 160, null: false
    t.string "description", limit: 300, default: "", null: false
    t.text "content", default: "", null: false
    t.jsonb "facts", default: {}, null: false, comment: "client, location, year, scope"
    t.uuid "cover_image_id"
    t.uuid "author_id"
    t.string "publication_state", default: "draft", null: false
    t.jsonb "draft_content"
    t.integer "lock_version", default: 0, null: false
    t.datetime "published_at"
    t.datetime "archived_at"
    t.boolean "featured_on_home", default: false, null: false
    t.integer "home_position", default: 0, null: false
    t.uuid "image_ids", default: [], null: false, array: true
    t.uuid "video_ids", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_pages_on_author_id"
    t.index ["category", "publication_state"], name: "index_pages_on_category_and_publication_state"
    t.index ["cover_image_id"], name: "index_pages_on_cover_image_id"
    t.index ["image_ids"], name: "index_pages_on_image_ids", using: :gin
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["video_ids"], name: "index_pages_on_video_ids", using: :gin
    t.check_constraint "publication_state::text = ANY (ARRAY['draft'::character varying, 'published'::character varying]::text[])", name: "page_publication_state"
  end

  create_table "taggings", force: :cascade do |t|
    t.uuid "page_id", null: false
    t.bigint "tag_id", null: false
    t.index ["page_id", "tag_id"], name: "index_taggings_on_page_id_and_tag_id", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 20, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "role", default: "visitor", null: false
    t.string "name", default: "", null: false
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "banned", default: false, null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "videos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.string "file", default: "", null: false
    t.string "published_file"
    t.integer "width", default: 0, null: false
    t.integer "height", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((title)::text)", name: "index_videos_on_title", unique: true
  end

  add_foreign_key "pages", "images", column: "cover_image_id"
  add_foreign_key "pages", "users", column: "author_id"
  add_foreign_key "taggings", "pages"
  add_foreign_key "taggings", "tags"
end
