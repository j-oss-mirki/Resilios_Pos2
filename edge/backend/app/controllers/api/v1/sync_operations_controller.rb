module Api
  module V1
    class SyncOperationsController < BaseController
      # GET /api/v1/sync_operations → Solo los pendientes
      def index
        @pending = SyncOperation.where(synced: false).order(created_at: :asc)
        render json: @pending, status: :ok
      end

      # PATCH /api/v1/sync_operations/:id → Marcar como sincronizado
      def update
        @op = SyncOperation.find(params[:id])
        if @op.update(synced: true, synced_at: Time.current)
          head :no_content
        else
          render_error("No se pudo actualizar", :unprocessable_entity)
        end
      end
    end
  end
end
