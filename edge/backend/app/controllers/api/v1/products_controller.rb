module Api
  module V1
    class ProductsController < BaseController
      before_action :set_product, only: [:show, :update, :destroy]

      # GET /api/v1/products
      # Respuesta rápida: solo campos necesarios, sin datos extra
      def index
        @products = Product.all.order(active: :desc, name: :asc)
        render json: @products, only: [:ulid, :name, :price, :tax_rate, :category, :active], status: :ok
      end

      # GET /api/v1/products/:id
      def show
        render json: @product, status: :ok
      end

      # POST /api/v1/products
      def create
        @product = Product.new(product_params)
        if @product.save
          # ✅ REGISTRO DE SINCRONIZACIÓN (Outbox Pattern)
          SyncOperation.create!(
            entity_type: 'Product',
            entity_id: @product.id,
            operation: 'create',
            data: @product.as_json,
            synced: false
          )
          render json: @product, status: :created, location: api_v1_product_url(@product)
        else
          render_error(@product.errors.full_messages)
        end
      end

      # PATCH / PUT /api/v1/products/:id
      def update
        if @product.update(product_params)
          # ✅ REGISTRO DE SINCRONIZACIÓN
          SyncOperation.create!(
            entity_type: 'Product',
            entity_id: @product.id,
            operation: 'update',
            data: @product.as_json,
            synced: false
          )
          render json: @product, status: :ok
        else
          render_error(@product.errors.full_messages)
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product.destroy
        # ✅ REGISTRO DE SINCRONIZACIÓN
        SyncOperation.create!(
          entity_type: 'Product',
          entity_id: @product.id,
          operation: 'delete',
          data: { id: @product.id, ulid: @product.ulid },
          synced: false
        )
        head :no_content
      end

      private
      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Producto no encontrado", :not_found)
      end

      # Solo permitir estos campos (seguridad)
      def product_params
        params.require(:product).permit(:name, :description, :price, :tax_rate, :category, :active)
      end
    end
  end
end
