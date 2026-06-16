module Api
  module V1
    class OrdersController < BaseController
      # GET /api/v1/orders
      def index
        @orders = Order.all.order(created_at: :desc)
        render json: @orders, status: :ok
      end

      # GET /api/v1/orders/:id
      def show
        @order = Order.find(params[:id])
        render json: @order, status: :ok
      end

      # POST /api/v1/orders  <-- ESTE ES EL FLUJO PRINCIPAL (US-01)
      def create
        @order = Order.new(order_params)
        if @order.save
          # ✅ AQUÍ LA MAGIA: Al guardar, el modelo Order dispara automáticamente
          # la creación del SyncOperation. NO necesitas escribir código extra.
          render json: { 
            order: @order, 
            message: "Pedido registrado correctamente",
            sync_status: "pending" # Indicador para el frontend
          }, status: :created
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/orders/:id
      def update
        @order = Order.find(params[:id])
        if @order.update(order_params)
          render json: @order, status: :ok
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/orders/:id
      def destroy
        @order = Order.find(params[:id])
        @order.destroy
        head :no_content
      end

      private

      def order_params
        params.require(:order).permit(:table_number, :waiter_name, :total_amount, :status, :payment_status)
      end
    end
  end
end
