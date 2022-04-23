class Admin::ClientsController < Admin::AdminController
  def index
    begin
      clients = Client.all
      raise 'Nenhum cliente' unless clients.any?

      clients.each do |client|
        Order.pull_orders(client.eni)
      end
    rescue StandardError
      flash.now[:alert] = 'Falha ao atualizar clientes! Se algum cliente não aparecer, tente novamente mais tarde'
    end

    @clients = all_clients
  end

  def show
    @client = Client.find(params[:id])
    @orders = @client.orders
    @products = @client.products
  end

  private

  def all_clients
    return Client.all if params[:busca].nil?

    Client.where('email like ? OR eni = ?', "%#{params[:busca]}%", params[:busca])
  end
end
