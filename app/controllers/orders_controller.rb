class OrdersController < ApplicationController
  before_action :authenticate_client!

  def index
    begin
      Order.pull_orders(current_client.eni)
    rescue StandardError
      flash.now[:alert] = 'Falha ao atualizar pedidos! Se seu pedido não aparecer, tente novamente mais tarde'
    end
    @status = Order.status
    @orders = Order.where(search)
  end

  def show
    @order = Order.find(params[:id])
    @credit_cards = CreditCard.where(client_id: current_client.id, active: :up)
    @payment_status = check_payment_status
    return redirect_to orders_path, alert: 'Não foi possível carregar dados do pedido no momento' if @order.nil?
    return redirect_to orders_path, alert: 'Objeto não encontrado' if @order == 404
  end

  def pay
    result = Order.payment_order(pay_params)
    if result == true
      flash['notice'] = 'Pagamento aguardando aprovação'
      redirect_to orders_path
    else
      msg = result.nil? ? 'Não foi possível efetuar pagamento no momento' : result
      render_show(msg)
    end
  end

  def cancel
    order = Order.find(params[:id])
    if order.pending?
      if order.cancel
        redirect_to order, notice: 'Pedido cancelado com sucesso'
      else
        render_index('Falha ao cancelar o pedido, tente novamente mais tarde!')
      end
    else
      render_index('Apenas pedidos Pendentes podem ser cancelados')
    end
  end

  private

  def pay_params
    { 'order_code' => params[:order_code], 'token' => params[:code_token],
      'installment' => params[:installment], 'cupom' => params[:cupom],
      'client_eni' => params[:client_eni], 'price' => params[:product_price], 'group' => params[:group] }
  end

  def search
    query = { client_id: current_client.id }
    search_by_status(query)
    search_by_order_code(query)
    query
  end

  def search_by_status(query)
    query[:status] = params[:status] unless params[:status].nil? || params[:status] == ''
  end

  def search_by_order_code(query)
    query[:order_code] = params[:search] unless params[:search].nil? || params[:search] == ''
  end

  def render_index(msg)
    @status = Order.status
    @orders = Order.where(search)
    flash.now['alert'] = msg
    render :index
  end

  def render_show(msg)
    @order = Order.find(params[:id])
    @credit_cards = CreditCard.where(client_id: current_client.id, active: :up)
    @payment_status = check_payment_status
    flash.now['alert'] = msg
    render :show
  end
end
