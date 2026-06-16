class CreateSyncOperations < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_operations, id: false do |t|
      # ID primario ULID (estándar página 10)
      t.string :id, primary_key: true, null: false

      # Datos de la operación
      t.string :entity_type, null: false  # Order, Product, Table...
      t.string :entity_id, null: false    # ULID del registro modificado
      t.string :operation, null: false    # create, update, destroy
      t.jsonb :payload, null: false       # Datos completos del cambio

      # Estado de sincronización
      t.string :status, null: false, default: 'pending' # pending → sent → confirmed → failed
      t.datetime :synced_at
      t.text :error_message

      # Trazabilidad
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      # Índices para rendimiento
      t.index [:status, :created_at]
      t.index [:entity_type, :entity_id]
    end
  end
end
