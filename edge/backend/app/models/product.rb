class Product < ApplicationRecord
  # ✅ ULID AUTOMÁTICO

  # ✅ CATEGORÍAS EJEMPLO (puedes agregar más)
  enum :category, {
    food:    'food',
    drink:   'drink',
    dessert: 'dessert',
    other:   'other'
  }

  # ✅ VALIDACIONES
  validates :name, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :available, inclusion: { in: [true, false] }

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
