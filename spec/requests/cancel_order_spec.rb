require 'rails_helper'

describe 'cliente cancela pedido' do
  it 'somente pedido pendente pode ser cancelado' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client, status: :completed)
    create(:product, order: order, client: client, status: :canceled)

    login_as(client, scope: :client)
    post "/orders/#{order.id}/cancel", params: '{}'

    expect(flash[:alert]).to eq 'Apenas pedidos Pendentes podem ser cancelados'
  end
end
