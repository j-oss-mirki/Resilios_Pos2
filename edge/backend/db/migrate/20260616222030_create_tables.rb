class CreateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :tables, id: :uuid do |t|
      t.integer :number
      t.string :status
      t.integer :capacity

      t.timestamps
    end
  end
end
