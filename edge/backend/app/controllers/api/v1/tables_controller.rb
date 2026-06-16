module Api
  module V1
    class TablesController < BaseController
      before_action :set_table, only: [:show, :update, :destroy]

      # GET /api/v1/tables
      def index
        @tables = Table.all.order(number: :asc)
        render json: @tables, status: :ok
      end

      # GET /api/v1/tables/:id
      def show
        render json: @table, status: :ok
      end

      # POST /api/v1/tables
      def create
        @table = Table.new(table_params)
        if @table.save
          SyncOperation.create!(
            entity_type: 'Table',
            entity_id: @table.id,
            operation: 'create',
            data: @table.as_json,
            synced: false
          )
          render json: @table, status: :created
        else
          render_error(@table.errors.full_messages)
        end
      end

      # PATCH /api/v1/tables/:id
      def update
        if @table.update(table_params)
          SyncOperation.create!(
            entity_type: 'Table',
            entity_id: @table.id,
            operation: 'update',
            data: @table.as_json,
            synced: false
          )
          render json: @table, status: :ok
        else
          render_error(@table.errors.full_messages)
        end
      end

      # DELETE /api/v1/tables/:id
      def destroy
        @table.destroy
        SyncOperation.create!(
          entity_type: 'Table',
          entity_id: @table.id,
          operation: 'delete',
          data: { id: @table.id },
          synced: false
        )
        head :no_content
      end

      private
      def set_table
        @table = Table.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Mesa no encontrada", :not_found)
      end

      def table_params
        params.require(:table).permit(:number, :capacity, :status, :location)
      end
    end
  end
end
