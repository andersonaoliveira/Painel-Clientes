class Api::V1::OrdersController < Api::V1::ApiController
  def payment
    @order_code = params['order_code']
    @price = params['total_charge']
    @order_status = params['status']
    @order = Order.find_by(order_code: @order_code)
    @product = Product.find_by(order: @order)
    if @order.nil?
      render json: '{"alert": "Pedido não encontrado"}', status: :not_found
    else
      status_update
    end
  end

  def cancelation
    order = Order.find_by(order_code: params[:id])
    unless order.canceled? || order.completed?
      order.canceled!
      return render json: order.as_json(except: %i[created_at updated_at]), status: :ok
    end
    render json: '{"alert": "Pedido já foi concluído ou cancelado"}', status: :not_acceptable
  end

  private

  def status_update
    if @order.waiting_payment_aproval?
      @order.update(status: @order_status)
      if @order_status == 'paid'
        @product.update(status: @order_status, price: @price)
        @product.install if check_products_status
      end
      render json: '{"alert": "Status do pedido alterado com sucesso"}', status: :ok
    else
      render json: '{"alert": "Pedido não liberado para pagamento"}', status: :not_acceptable
    end
  end
end
