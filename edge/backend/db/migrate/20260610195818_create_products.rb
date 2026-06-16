class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products, id: :uuid do |t|
      # ULID: Identificador único de negocio (estándar del proyecto)
      t.string :ulid, null: false, index: { unique: true }
      
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0.0
      t.string :category
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
