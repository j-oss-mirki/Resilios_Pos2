# app/controllers/api/v1/health_controller.rb
module Api
  module V1
    class HealthController < BaseController
      # GET /api/v1/health
      def check
        render json: {
          status: "operational",
          mode: "offline-first",
          timestamp: Time.now.iso8601,
          edge_version: "1.0.0-mvp",
          database: "SQLite WAL (local)",
          request_id: headers['X-Request-ID']
        }, status: :ok
      end
    end
  end
end
