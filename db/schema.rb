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

ActiveRecord::Schema[7.1].define(version: 2024_06_20_092215) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blocked_users", force: :cascade do |t|
    t.integer "blocking_user"
    t.integer "blocked_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "reel_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delete_requests", force: :cascade do |t|
    t.integer "user_id"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fav_musics", force: :cascade do |t|
    t.integer "user_id"
    t.integer "music_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", force: :cascade do |t|
    t.string "following_id"
    t.string "follower_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "reel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "musics", force: :cascade do |t|
    t.string "title"
    t.string "music_url"
    t.string "image_url"
    t.string "singer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string "user_id"
    t.string "creator_id"
    t.string "reel_id"
    t.string "content"
    t.string "notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "user_id"
    t.string "amount"
    t.string "payment_id"
    t.string "order_id"
    t.string "receipt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reels", force: :cascade do |t|
    t.integer "music_id"
    t.string "description"
    t.string "hastags"
    t.boolean "allow_comments"
    t.integer "like_count", default: 0
    t.integer "view_count", default: 0
    t.integer "report_count", default: 0
    t.integer "creater_id"
    t.boolean "isReported", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_approved", default: false
  end

  create_table "reported_reels", force: :cascade do |t|
    t.string "reporting_reason"
    t.string "description"
    t.string "user_id"
    t.string "reel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "device_id"
    t.string "device_type"
    t.string "device_name"
    t.string "social_type"
    t.string "social_id"
    t.string "social_email"
    t.string "social_name"
    t.string "user_name"
    t.string "social_img_url"
    t.string "advertising_id"
    t.string "version_name"
    t.string "version_code"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "referal_url"
    t.string "refer_code"
    t.string "source_ip"
    t.string "security_token"
    t.boolean "is_verified", default: false
    t.boolean "show_liked_reels", default: true
    t.string "category"
    t.string "bio"
    t.string "facebook_url"
    t.string "insta_url"
    t.string "yt_url"
    t.string "status", default: "Verification Request"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "wallet_balance", default: 0
  end

  create_table "verification_requests", force: :cascade do |t|
    t.string "user_id"
    t.string "social_type"
    t.string "social_id"
    t.string "status", default: "Verification Request"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
