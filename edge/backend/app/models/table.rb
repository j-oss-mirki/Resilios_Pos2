class Table < ApplicationRecord
  # ✅ ULID AUTOMÁTICO (YA CONFIGURADO GLOBALMENTE)

  # ✅ ESTADOS DE MESA
  enum :status, {
    free:     'free',
    occupied: 'occupied',
    reserved: 'reserved',
    closed:   'closed'
  }, default: 'free'

  # ✅ VALIDACIONES
  validates :number, :capacity, presence: true
  validates :number, numericality: { only_integer: true, greater_than: 0 }
  validates :capacity, numericality: { only_integer: true, in: 1..20 }

  # ✅ PATRÓN OUTBOX (IGUAL QUE EN ORDER)
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
