class CreateSyncOperations < ActiveRecord::Migration[8.0]
  def change
    create_table :sync_operations, id: false do |t|
      # ✅ ESTÁNDAR 4.4: ULID
      t.string :id, primary_key: true, limit: 26

      t.string :entity_type, null: false
      t.string :entity_id, null: false
      t.string :operation, null: false # upsert / delete
      t.json :data
      t.boolean :synced, default: false
      t.datetime :synced_at
      t.integer :retry_count, default: 0

      t.timestamps
    end
    add_index :sync_operations, [:synced, :entity_type]
  end
end
