class ProductsController < ApplicationController
  before_action :authenticate_client!

  def index
    @products = current_client.products
    products_instal(@product)
    @active_products = current_client.products.installed + current_client.products.installing
    @cancelled_products = current_client.products.canceled
  end

  def show
    @product = Product.find(params[:id])
    @product.install if @product.installing? && check_products_status

    return if @product.owner?(current_client)

    redirect_to root_path, alert: 'Você não tem autorização para acessar esta página'
  end

  def cancel
    product = Product.find(params[:id])
    if product.owner?(current_client)
      if product.cancel
        redirect_to product, notice: 'Produto cancelado com sucesso'
      else
        redirect_to product, alert: 'Falha ao cancelar o produto, tente novamente mais tarde!'
      end
    else
      redirect_to root_path, alert: 'Você não tem autorização para isso'
    end
  end

  def buy
    @product = Product.find(params['id'])
    @client = current_client
    @plans = Plan.group_search(@product.group)
  end

  def choose_period
    @product = Product.find(params['id'])
    @client = current_client
    @plan = Plan.find(params['plan'].to_i)
    @prices = Price.all(params['plan'])
  end

  def create_order
    price = Price.find(params[:price], params[:plan_id])
    order_params = params.permit(:client_eni, :plan_id)
    order = Product.send_order(order_params, price[0].value, price[0].period)
    redirect_order(order)
  end

  private

  def redirect_order(order)
    if order.nil? || order.is_a?(Array)
      redirect_to product_path(params['id']), alert: 'Falha ao criar pedido, tente novamente mais tarde!'
    else
      redirect_to orders_path, notice: 'Pedido criado com sucesso'
    end
  end

  def products_instal(products)
    products&.each { |prod| prod.install if prod.paid? && check_products_status }
  end
end
