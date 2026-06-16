module Api
  module V1
    class OrdersController < ApplicationController
      # ✅ Desactivar protección CSRF (API-only)
      def verify_authenticity_token; end

      # ✅ Endpoint definido en WP-2.2
      def create
        @order = Order.new(order_params)

        if @order.save
          render json: {
            success: true,
            message: "✅ Pedido guardado LOCALMENTE (SQLite - OFFLINE)",
            order_id: @order.id,
            data: @order
          }, status: :created
        else
          render json: { 
            success: false,
            error: @order.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      private
      def order_params
        params.require(:order).permit(:table_number, :waiter_name, :total_amount, :status)
      end
    end
  end
end
