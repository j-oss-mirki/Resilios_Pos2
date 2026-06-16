# app/controllers/rails/health_controller.rb
class Rails::HealthController < ApplicationController
  def show
    render json: { estado: "ok", mensaje: "API funcionando correctamente", fecha: Time.now.iso8601 }, status: :ok
  end
end
