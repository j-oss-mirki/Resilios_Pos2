class SyncOperation < ApplicationRecord
end
class SyncOperation < ApplicationRecord
  # Estándar: ULID como ID primario
  self.primary_key = :id

  # Enumeraciones definidas
  enum status: { pending: 'pending', sent: 'sent', confirmed: 'confirmed', failed: 'failed' }
  enum operation: { create: 'create', update: 'update', destroy: 'destroy' }

  # Generar ULID antes de crear
  before_create :generate_ulid_id

  # Validaciones
  validates :entity_type, :entity_id, :operation, :payload, presence: true

  private

  def generate_ulid_id
    self.id = Time.now.to_i.to_s(36) + SecureRandom.alphanumeric(10).downcase
  end
end
