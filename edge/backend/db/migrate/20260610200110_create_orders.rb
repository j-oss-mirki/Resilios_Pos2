class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, id: false do |t|
      t.string :id, primary_key: true, null: false

      # Campos definidos en historias de usuario
      t.integer :table_number, null: false
      t.string :waiter_name, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      
      # Estados según US-01 y US-04
      t.string :status, null: false, default: 'pending' # pending → preparing → ready → delivered → cancelled
      t.string :payment_status, null: false, default: 'unpaid' # unpaid → paid → partial

      # Trazabilidad
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
