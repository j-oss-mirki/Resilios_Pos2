class OrderItem < ApplicationRecord
  # ✅ ULID AUTOMÁTICO

  # ✅ RELACIONES CRÍTICAS
  belongs_to :order
  belongs_to :product

  # ✅ VALIDACIONES
  validates :quantity, :unit_price, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  # ✅ PATRÓN OUTBOX
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
