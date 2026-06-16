class CreateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :tables, id: :uuid do |t|
      t.string :ulid, null: false, index: { unique: true }
      t.integer :number, null: false, index: { unique: true } # Número de mesa único
      t.integer :capacity
      t.string :status, default: 'free'
      t.string :location

      t.timestamps
    end
  end
end
