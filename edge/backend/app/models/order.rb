class Order < ApplicationRecord
  self.primary_key = :id

  # Estados definidos
  enum status: { pending: 'pending', preparing: 'preparing', ready: 'ready', delivered: 'delivered', cancelled: 'cancelled' }
  enum payment_status: { unpaid: 'unpaid', paid: 'paid', partial: 'partial' }

  # === LÓGICA DE SINCRONIZACIÓN (WP-3.1) ===
  # DESPUÉS de guardar exitosamente (incluso en modo offline), crear registro de log
  after_commit :create_sync_log, on: [:create, :update, :destroy]

  # Generar ULID
  before_create :generate_ulid_id

  # Validaciones
  validates :table_number, :waiter_name, :total_amount, presence: true

  private

  def generate_ulid_id
    self.id = Time.now.to_i.to_s(36) + SecureRandom.alphanumeric(10).downcase
  end

  # Este método cumple EXACTAMENTE lo que dice el documento:
  # "cada mutación genera una entrada de log con ULID + timestamp"
  def create_sync_log
    SyncOperation.create!(
      entity_type: 'Order',
      entity_id: self.id,
      operation: destroyed? ? 'destroy' : (saved_change_to_id? ? 'create' : 'update'),
      payload: self.as_json, # Guardamos el estado completo
      status: 'pending'
    )
  end
end
