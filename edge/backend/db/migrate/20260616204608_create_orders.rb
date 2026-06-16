class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: false do |t|
      # ✅ ESTÁNDAR 4.4: ULID (Clave primaria como texto)
      t.string :id, primary_key: true, limit: 26

      # ✅ CAMPOS DEFINIDOS EN WP-2.1
      t.integer :table_number, null: false
      t.string :waiter_name, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
