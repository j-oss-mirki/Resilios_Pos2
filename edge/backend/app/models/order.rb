class Order < ApplicationRecord
  # ✅ ULID SE GENERA AUTOMÁTICAMENTE DESDE EL INICIALIZADOR

  # ✅ ESTADOS DE PEDIDO (WP-2.1)
  enum :status, {
    pending:     'pending',
    in_progress: 'in_progress',
    ready:       'ready',
    delivered:   'delivered',
    cancelled:   'cancelled'
  }, default: 'pending'

  # ✅ VALIDACIONES
  validates :table_number, :waiter_name, :total_amount, presence: true
  validates :total_amount, numericality: { greater_than: 0 }

  # ✅ PATRÓN OUTBOX (WP-3.1)
  after_create  :log_sync
  after_update  :log_sync
  after_destroy :log_sync

  private
  def log_sync
    SyncOperation.create!(
      entity_type: self.class.name,
      entity_id: self.id,
      operation: destroyed? ? 'delete' : 'upsert',
      data: self.as_json,
      synced: false
    )
  end
end
