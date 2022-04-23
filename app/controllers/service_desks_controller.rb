class ServiceDesksController < ApplicationController
  before_action :authenticate_client!
  before_action :set_service_desk, only: %i[show edit update destroy]

  def index
    @service_desks = service_desks
    @status = ServiceDesk.status
    @categories = take_categories
  end

  def show
    @message = Message.new if @service_desk.in_progress?
    @messages = Message.where(service_desk_id: @service_desk.id) unless @service_desk.open?
    return unless @service_desk.client.id != current_client.id

    redirect_to service_desks_path, alert: 'Chamado não encontrado!'
  end

  def new
    @service_desk = ServiceDesk.new
    @categories = Category.all_categories
    @orders_products = take_orders_and_products(current_client.id)
  end

  def create
    service_desk_params = params.require(:service_desk).permit(:client_id, :category_id, :order_id, :product_id,
                                                               :description)
    @service_desk = ServiceDesk.new(service_desk_params)
    return redirect_to service_desk_path(@service_desk.id), notice: 'Chamado aberto com sucesso!' if @service_desk.save

    @categories = Category.all_categories
    @orders_products = take_orders_and_products(current_client.id)
    flash.now['alert'] = 'Não foi possível abrir chamado'
    render 'new'
  end

  def edit
    @categories = Category.all_categories
    @orders_products = take_orders_and_products(current_client.id)
  end

  def update
    service_desk_params = params.require(:service_desk).permit(:client_id, :category_id, :order_id, :product_id,
                                                               :description)
    if @service_desk.update(service_desk_params)
      return redirect_to service_desk_path(@service_desk.id), notice: 'Chamado alterado com sucesso!'
    end

    @categories = Category.all_categories
    @orders_products = take_orders_and_products(current_client.id)
    flash.now['alert'] = 'Não foi possível editar chamado'
    render 'edit'
  end

  def destroy
    return unless @service_desk.open?

    @service_desk.destroy
    redirect_to service_desks_path, notice: 'Chamado excluído com sucesso'
  end

  def change_to_wait_approval_client
    service_desk = ServiceDesk.find(params[:id])
    return redirect_to service_desks_path unless service_desk.in_progress?

    service_desk.wait_approval_client!
    flash['notice'] = 'Chamado finalizado com sucesso. Não se esqueça de responder à pesquisa.'
    redirect_to service_desk_path(service_desk.id)
  end

  def close
    service_desk = ServiceDesk.find(params[:id])
    return redirect_to service_desks_path unless service_desk.wait_approval_client?

    service_desk.update(survey: params[:survey])
    service_desk.closed!
    flash['notice'] = 'Obrigado pela resposta. Qualquer dúvida entre em contato conosco.'
    redirect_to service_desk_path(service_desk.id)
  end

  private

  def set_service_desk
    @service_desk = ServiceDesk.find(params[:id])
  end

  def take_orders_and_products(client_id)
    orders = Order.where(client_id: client_id)
    orders_products = []
    orders_products << ['Selecione o seu Pedido/Produto', nil]
    return orders_products if orders.empty?

    # rubocop:disable Layout/LineLength
    orders_products + orders.map { |order| ["##{order.order_code} - #{order.product.name unless order.product.nil?}", order.id] }
    # rubocop:enable Layout/LineLength
  end

  def take_categories
    category_all = Category.all_categories
    categories = []
    categories << ['Categoria', nil]
    categories + category_all.map { |category| [category.name, category.id] }
  end

  def service_desks
    @service_desks = ServiceDesk.where(client_id: current_client.id)
    @service_desks = @service_desks.where(search)
  end

  def search
    query = {}
    search_by_status(query)
    search_by_category(query)
    search_by_order(query)
    query
  end

  def search_by_status(query)
    query[:status] = params[:status] unless params[:status].nil? || params[:status] == ''
  end

  def search_by_category(query)
    query[:category_id] = params[:category_id] unless params[:category_id].nil? || params[:category_id] == ''
  end

  def search_by_order(query)
    query[:order_id] = params[:search].to_i unless params[:search].nil? || params[:search] == ''
  end
end
