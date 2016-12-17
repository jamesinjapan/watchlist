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

ActiveRecord::Schema.define(version: 20161217012649) do

  create_table "movies", force: :cascade do |t|
    t.string  "title"
    t.string  "genres"
    t.string  "imdb"
    t.string  "tmdb"
    t.string  "certification"
    t.date    "last_checked"
    t.date    "release_date"
    t.string  "poster_path"
    t.string  "gb_id"
    t.boolean "availability_online"
    t.string  "imdb_rating"
  end

  add_index "movies", ["imdb"], name: "imdb_ix"
  add_index "movies", ["title"], name: "title_ix"
  add_index "movies", ["tmdb"], name: "tmdb_ix"

  create_table "old_users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
  end

  create_table "ratings", force: :cascade do |t|
    t.string  "rating"
    t.integer "movie_id"
    t.integer "user_id"
  end

  add_index "ratings", ["movie_id"], name: "index_ratings_on_movie_id"
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id"

  create_table "tag_keys", force: :cascade do |t|
    t.string "tag_text"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "tag_key_id"
    t.integer "movie_id"
  end

  add_index "tags", ["movie_id"], name: "index_tags_on_movie_id"
  add_index "tags", ["tag_key_id"], name: "index_tags_on_tag_key_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "certificate_limit"
    t.string   "watchlist"
    t.string   "recommendations"
  end

end
