class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items, id: :uuid do |t|
      t.string :ulid, null: false, index: { unique: true }
      t.string :order_id, null: false   # Relación con pedido
      t.string :product_id, null: false  # Relación con producto
      t.integer :quantity, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :notes

      t.timestamps
    end
  end
end
