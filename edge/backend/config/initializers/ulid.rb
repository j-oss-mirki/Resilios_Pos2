# config/initializers/ulid.rb
# ✅ ESTÁNDAR 4.4: ULID - Identificador único ordenable
# Implementación según especificación ResiliOS POS

require 'ulid'

# Método para generar ULID válido
def generar_ulid_resilios
  ULID.generate
end

# Habilitar generación automática en todos los modelos que lo usen
module Resilios
  module ULID
    extend ActiveSupport::Concern

    included do
      before_create :assign_ulid_id
    end

    private

    def assign_ulid_id
      self.id = generar_ulid_resilios if self.id.blank?
    end
  end
end

# Incluir módulo en ApplicationRecord para que todos los modelos lo hereden
ActiveRecord::Base.include Resilios::ULID
