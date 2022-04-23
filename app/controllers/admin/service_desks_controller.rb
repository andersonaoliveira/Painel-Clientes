class Admin::ServiceDesksController < Admin::AdminController
  def index
    @service_desks = service_desks('all')
    @status = ServiceDesk.status
    @categories = take_categories
  end

  def show
    @service_desk = ServiceDesk.find(params[:id])
    @message = Message.new if @service_desk.in_progress?
    @messages = Message.where(service_desk_id: @service_desk.id) if @service_desk.in_progress?
  end

  def my_service_desks
    @service_desks = service_desks('my')
    @status = ServiceDesk.status
    @categories = take_categories
  end

  def assign_service_desk
    service_desk = ServiceDesk.find(params[:id])
    return redirect_to admin_service_desks_path, alert: 'Não foi possível atribuir chamado' unless service_desk.open?

    service_desk.update(admin_id: current_admin.id)
    service_desk.in_progress!
    redirect_to admin_service_desk_path(service_desk.id), notice: 'Chamado atribuído com sucesso!'
  end

  def close
    service_desk = ServiceDesk.find(params[:id])
    return redirect_to admin_service_desks_path unless service_desk.in_progress?

    service_desk.wait_approval_client!
    flash['notice'] = 'Chamado finalizado com sucesso.'
    redirect_to admin_service_desk_path(service_desk.id)
  end

  private

  def take_categories
    category_all = Category.all
    categories = []
    categories << ['Categoria', nil]
    categories + category_all.map { |category| [category.name, category.id] }
  end

  def service_desks(type)
    @service_desks = ServiceDesk.all if type == 'all'
    @service_desks = ServiceDesk.where(admin_id: current_admin.id) unless type == 'all'
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
