# Generador ULID propio - Estándar ResiliOS POS
# Código puro, SIN GEMAS EXTERNAS, cumple especificación ULID
Rails.application.config.to_prepare do
  ActiveRecord::Base.class_eval do
    before_create :generar_ulid_resilios

    private
    def generar_ulid_resilios
      # Solo generar si no tiene ya uno
      return if self.ulid.present?

      # Caracteres permitidos estándar ULID (Crockford Base32)
      caracteres = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
      ulid_final = ""

      # 1. Parte de tiempo (10 caracteres) - ordenable cronológicamente
      tiempo_ms = (Time.now.to_f * 1000).to_i
      10.times do |i|
        indice = (tiempo_ms / (32 ** (9 - i))) % 32
        ulid_final << caracteres[indice]
      end

      # 2. Parte aleatoria (16 caracteres) - unicidad garantizada
      16.times do
        ulid_final << caracteres[rand(32)]
      end

      # Asignar al campo
      self.ulid = ulid_final
    end
  end
end
