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

ActiveRecord::Schema[8.1].define(version: 2026_06_16_204642) do
  create_table "orders", id: { type: :string, limit: 26 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "pending", null: false
    t.integer "table_number", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.string "waiter_name", null: false
  end

  create_table "sync_operations", id: { type: :string, limit: 26 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "data"
    t.string "entity_id", null: false
    t.string "entity_type", null: false
    t.string "operation", null: false
    t.integer "retry_count", default: 0
    t.boolean "synced", default: false
    t.datetime "synced_at"
    t.datetime "updated_at", null: false
    t.index ["synced", "entity_type"], name: "index_sync_operations_on_synced_and_entity_type"
  end
end
