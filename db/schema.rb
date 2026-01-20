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

ActiveRecord::Schema[8.1].define(version: 2026_01_20_153209) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "commission_updates", force: :cascade do |t|
    t.text "body"
    t.bigint "commission_id", null: false
    t.datetime "created_at", null: false
    t.boolean "notify_customer", default: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "visible_to_customer", default: true
    t.index ["commission_id"], name: "index_commission_updates_on_commission_id"
    t.index ["created_at"], name: "index_commission_updates_on_created_at"
    t.index ["user_id"], name: "index_commission_updates_on_user_id"
  end

  create_table "commissions", force: :cascade do |t|
    t.date "actual_completion_date"
    t.date "actual_start_date"
    t.datetime "created_at", null: false
    t.text "customer_notes"
    t.date "delivered_at"
    t.decimal "deposit_amount", precision: 10, scale: 2
    t.boolean "deposit_paid", default: false
    t.date "deposit_paid_at"
    t.text "description"
    t.string "dimensions"
    t.date "estimated_completion_date"
    t.decimal "estimated_price", precision: 10, scale: 2
    t.date "estimated_start_date"
    t.decimal "final_price", precision: 10, scale: 2
    t.text "internal_notes"
    t.string "location"
    t.string "status", default: "inquiry", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_commissions_on_created_at"
    t.index ["status"], name: "index_commissions_on_status"
    t.index ["user_id"], name: "index_commissions_on_user_id"
  end

  create_table "contact_inquiries", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "phone"
    t.datetime "responded_at"
    t.string "status", default: "new", null: false
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_contact_inquiries_on_created_at"
    t.index ["email"], name: "index_contact_inquiries_on_email"
    t.index ["status"], name: "index_contact_inquiries_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "work_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_id", null: false
    t.index ["category_id"], name: "index_work_categories_on_category_id"
    t.index ["work_id", "category_id"], name: "index_work_categories_on_work_id_and_category_id", unique: true
    t.index ["work_id"], name: "index_work_categories_on_work_id"
  end

  create_table "works", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "dimensions"
    t.boolean "featured", default: false
    t.string "medium"
    t.integer "position", default: 0
    t.boolean "published", default: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "year_created"
    t.index ["featured"], name: "index_works_on_featured"
    t.index ["position"], name: "index_works_on_position"
    t.index ["published"], name: "index_works_on_published"
    t.index ["slug"], name: "index_works_on_slug", unique: true
    t.index ["year_created"], name: "index_works_on_year_created"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "commission_updates", "commissions"
  add_foreign_key "commission_updates", "users"
  add_foreign_key "commissions", "users"
  add_foreign_key "work_categories", "categories"
  add_foreign_key "work_categories", "works"
end
