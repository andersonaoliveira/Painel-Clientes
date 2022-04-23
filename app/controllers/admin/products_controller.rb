class Admin::ProductsController < Admin::AdminController
  def index
    begin
      clients = Client.all
      raise 'Nenhum cliente' unless clients.any?

      clients.each do |client|
        Order.pull_orders(client.eni)
      end
    rescue StandardError
      flash.now[:alert] = 'Falha ao atualizar pedidos! Se algum pedido não aparecer, tente novamente mais tarde'
    end
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def cancel
    product = Product.find(params[:id])
    if product.cancel
      redirect_to admin_product_path(product.id), notice: 'Produto cancelado com sucesso'
    else
      redirect_to admin_product_path(product.id), alert: 'Falha ao cancelar o produto, tente novamente mais tarde!'
    end
  end
end
