class SyncOperation < ApplicationRecord
  # ✅ ULID SE GENERA AUTOMÁTICAMENTE DESDE EL INICIALIZADOR

  # Inmutabilidad según definición de Done
  def readonly?
    synced? && !new_record?
  end
end
