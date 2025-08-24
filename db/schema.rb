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

ActiveRecord::Schema[8.0].define(version: 2025_08_24_185844) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "habits_item_tags", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "tag_id"], name: "index_habits_item_tags_on_item_id_and_tag_id", unique: true
    t.index ["item_id"], name: "index_habits_item_tags_on_item_id"
    t.index ["tag_id"], name: "index_habits_item_tags_on_tag_id"
  end

  create_table "habits_items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "item_type", default: 0, null: false
    t.integer "frequency", default: 0, null: false
    t.integer "days_mask"
    t.datetime "due_on"
    t.integer "position"
    t.datetime "archived_at"
    t.jsonb "data", default: {}, null: false
    t.bigint "list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_habits_items_on_list_id"
  end

  create_table "habits_lists", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "position"
    t.datetime "archived_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_habits_lists_on_user_id"
  end

  create_table "habits_tags", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_habits_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "habits_item_tags", "habits_items", column: "item_id"
  add_foreign_key "habits_item_tags", "habits_tags", column: "tag_id"
  add_foreign_key "habits_items", "habits_lists", column: "list_id"
  add_foreign_key "habits_lists", "users"
  add_foreign_key "habits_tags", "users"
end
