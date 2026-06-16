# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      # Estándares ResiliOS: CORS, formato JSON, trazabilidad ULID
      before_action :set_default_headers
      before_action :set_json_format
      before_action :add_request_tracing

      rescue_from ActiveRecord::RecordNotFound,       with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid,        with: :render_validation_error
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      private

      def set_default_headers
        headers['Access-Control-Allow-Origin']  = '*' # Cambiar en producción
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Request-ID, X-Edge-Version'
        headers['X-Edge-Node-ID'] = ENV['EDGE_NODE_ID'] || 'resilios-edge-01'
      end

      def set_json_format
        request.format = :json
      end

      def add_request_tracing
        request_id = request.headers['X-Request-ID'] || generate_ulid
        headers['X-Request-ID'] = request_id
      end

      # Generador ULID según estándar del proyecto
      def generate_ulid
        Time.now.to_i.to_s(36) + SecureRandom.alphanumeric(10).downcase
      end

      # Respuestas estandarizadas
      def render_not_found(exception)
        render json: {
          error: "Recurso no encontrado",
          message: exception.message,
          code: "NOT_FOUND",
          request_id: headers['X-Request-ID']
        }, status: :not_found
      end

      def render_validation_error(exception)
        render json: {
          error: "Datos inválidos",
          details: exception.record.errors.full_messages,
          code: "VALIDATION_ERROR",
          request_id: headers['X-Request-ID']
        }, status: :unprocessable_entity
      end

      def render_bad_request(exception)
        render json: {
          error: "Parámetros faltantes o incorrectos",
          message: exception.message,
          code: "BAD_REQUEST",
          request_id: headers['X-Request-ID']
        }, status: :bad_request
      end
    end
  end
end
