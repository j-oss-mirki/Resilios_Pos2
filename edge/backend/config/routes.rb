Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#check'

      # Rutas de Pedidos (CRUD completo)
      resources :orders, only: [:index, :show, :create, :update, :destroy]

      # Ruta para ver la cola de sincronización (para el Dashboard US-03)
      get 'sync_queue', to: 'sync_operations#index'
    end
  end
end
