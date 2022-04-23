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

ActiveRecord::Schema.define(version: 2022_02_11_061611) do

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
  end

  create_table "clients", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "eni"
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "legal_name"
    t.string "birth_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_clients_on_email", unique: true
    t.index ["reset_password_token"], name: "index_clients_on_reset_password_token", unique: true
  end

  create_table "credit_cards", force: :cascade do |t|
    t.string "token"
    t.string "nickname"
    t.integer "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "active", default: 0
    t.integer "card_banner_id"
    t.index ["client_id"], name: "index_credit_cards_on_client_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.integer "service_desk_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "client_id"
    t.integer "admin_id"
    t.index ["admin_id"], name: "index_messages_on_admin_id"
    t.index ["client_id"], name: "index_messages_on_client_id"
    t.index ["service_desk_id"], name: "index_messages_on_service_desk_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "order_code"
    t.integer "client_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "plan_id"
    t.string "frequency"
    t.string "price"
    t.index ["client_id"], name: "index_orders_on_client_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "group"
    t.string "plan"
    t.string "frequency"
    t.string "price"
    t.string "server"
    t.string "code"
    t.integer "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.integer "order_id", null: false
    t.index ["client_id"], name: "index_products_on_client_id"
    t.index ["order_id"], name: "index_products_on_order_id"
  end

  create_table "service_desks", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "client_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.integer "order_id"
    t.integer "admin_id"
    t.integer "survey", default: 0
    t.index ["admin_id"], name: "index_service_desks_on_admin_id"
    t.index ["category_id"], name: "index_service_desks_on_category_id"
    t.index ["client_id"], name: "index_service_desks_on_client_id"
    t.index ["order_id"], name: "index_service_desks_on_order_id"
  end

  add_foreign_key "credit_cards", "clients"
  add_foreign_key "messages", "admins"
  add_foreign_key "messages", "clients"
  add_foreign_key "messages", "service_desks"
  add_foreign_key "orders", "clients"
  add_foreign_key "products", "clients"
  add_foreign_key "products", "orders"
  add_foreign_key "service_desks", "admins"
  add_foreign_key "service_desks", "categories"
  add_foreign_key "service_desks", "clients"
  add_foreign_key "service_desks", "orders"
end
