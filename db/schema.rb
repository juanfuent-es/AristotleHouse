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

ActiveRecord::Schema[8.1].define(version: 2023_08_07_044021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "blocks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", limit: 10, default: "text", null: false, comment: "text | css | js | html | glsl"
    t.text "content"
    t.integer "number", default: 0, null: false
    t.uuid "page_id", null: false
    t.string "title", limit: 70, default: "", null: false
    t.index ["page_id"], name: "index_blocks_on_page_id"
  end

  create_table "clients", force: :cascade do |t|
    t.text "address"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "email"
    t.string "logo"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["country_id"], name: "index_clients_on_country_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type", default: "", null: false
    t.datetime "created_at", null: false
    t.text "message"
    t.string "status", default: "revision", null: false, comment: "revision|approved|rejected"
    t.datetime "updated_at", null: false
    t.bigint "visitor_id", null: false
    t.index ["visitor_id"], name: "index_comments_on_visitor_id"
  end

  create_table "countries", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "alpha_2", limit: 2, default: "", null: false
    t.string "alpha_3", limit: 3, default: "", null: false
    t.string "code", limit: 10, default: "", null: false
    t.string "continent", default: "", null: false
    t.string "name_en", default: "", null: false
    t.string "name_es", default: "", null: false
    t.string "sub_continent", default: "", comment: "Countries on two continents or in America (South|North)"
    t.index ["alpha_2"], name: "index_countries_on_alpha_2", unique: true
    t.index ["alpha_3"], name: "index_countries_on_alpha_3", unique: true
  end

  create_table "images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "alt", default: "", null: false
    t.string "bg", default: "#FFF"
    t.string "color", default: "#000"
    t.datetime "created_at", null: false
    t.string "extension", default: "", null: false
    t.string "file", default: ""
    t.integer "height", default: 0, null: false
    t.string "mime_type", default: "", null: false
    t.string "rainbow", default: "#FFF,#000"
    t.string "slug", default: "", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "width", default: 0, null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "count", default: 0
    t.uuid "page_id", null: false
    t.bigint "visitor_id", null: false
    t.index ["page_id"], name: "index_likes_on_page_id"
    t.index ["visitor_id", "page_id"], name: "index_likes_on_visitor_id_and_page_id", unique: true
    t.index ["visitor_id"], name: "index_likes_on_visitor_id"
  end

  create_table "ogs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "audio", default: ""
    t.string "category", default: "", null: false
    t.string "extension", default: "", null: false
    t.integer "height", default: 0
    t.string "image", default: ""
    t.string "mime_type", default: "", null: false
    t.string "video", default: ""
    t.integer "width", default: 0
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id"
    t.string "category", default: "", null: false, comment: "Static | Blog | Article | Tutorial | Course | Workshop"
    t.text "content"
    t.datetime "created_at", null: false
    t.string "keywords", default: ""
    t.string "lang", default: "es", null: false
    t.string "og_description", default: "", null: false
    t.string "og_image", default: ""
    t.string "og_title", default: "", null: false
    t.string "og_type", default: "website", null: false, comment: "audio|video|website"
    t.boolean "restricted", default: false, comment: "For static pages. e.g. Home, About, Contact, ..."
    t.string "slug", default: "", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "versionable_id", comment: "For languages versions"
    t.string "versionable_type"
    t.index ["author_id"], name: "index_pages_on_author_id"
    t.index ["versionable_type", "versionable_id"], name: "index_pages_on_versionable"
  end

  create_table "taggings", force: :cascade do |t|
    t.uuid "page_id", null: false
    t.bigint "tag_id", null: false
    t.index ["page_id"], name: "index_taggings_on_page_id"
    t.index ["tag_id", "page_id"], name: "index_taggings_on_tag_id_and_page_id", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 20, default: "", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar", default: "", null: false
    t.boolean "banned", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "visitor", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "username", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "file", default: "", null: false
    t.integer "height", default: 0, null: false
    t.string "slug", default: "", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "width", default: 0, null: false
  end

  create_table "visitors", force: :cascade do |t|
    t.string "ip", default: "", null: false
    t.string "location", default: "", null: false
    t.index ["ip"], name: "index_visitors_on_ip"
  end

  create_table "visits", force: :cascade do |t|
    t.integer "counter", default: 0, null: false
    t.uuid "page_id", null: false
    t.bigint "visitor_id", null: false
    t.index ["page_id", "visitor_id"], name: "index_visits_on_page_id_and_visitor_id", unique: true
    t.index ["page_id"], name: "index_visits_on_page_id"
    t.index ["visitor_id"], name: "index_visits_on_visitor_id"
  end

  add_foreign_key "blocks", "pages"
  add_foreign_key "clients", "countries"
  add_foreign_key "comments", "visitors"
  add_foreign_key "likes", "pages"
  add_foreign_key "likes", "visitors"
  add_foreign_key "pages", "users", column: "author_id"
  add_foreign_key "taggings", "pages"
  add_foreign_key "taggings", "tags"
  add_foreign_key "visits", "pages"
  add_foreign_key "visits", "visitors"
end
