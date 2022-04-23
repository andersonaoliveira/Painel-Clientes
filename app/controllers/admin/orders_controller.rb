class Admin::OrdersController < Admin::AdminController
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
    @orders = Order.all
  end

  def show
    @order = Order.find(params[:id])
    @product = @order.product
  end

  def cancel
    order = Order.find(params[:id])
    if order.pending?
      if order.cancel
        redirect_to admin_order_path(order.id), notice: 'Pedido cancelado com sucesso'
      else
        redirect_to admin_order_path(order.id), alert: 'Falha ao cancelar o pedido, tente novamente mais tarde!'
      end
    else
      redirect_to orders_path, alert: 'Apenas pedidos Pendentes podem ser cancelados'
    end
  end
end
