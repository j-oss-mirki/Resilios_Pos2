Rails.application.routes.draw do
  # ✅ RUTA PARA HEALTHCHECK DE DOCKER
  get "up" => "rails/health#show", as: :rails_health_check

  # Tus rutas actuales (INTACTAS)
  namespace :api do
    namespace :v1 do
      resources :orders, only: [:create] # Solo crear pedidos
    end
  end
end
