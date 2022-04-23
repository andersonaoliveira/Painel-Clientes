require 'rails_helper'

describe 'Cliente cancela uma ordem pendente' do
  it 'com sucesso' do
    client = create(:client)
    order1 = create(:order, order_code: '201546', client: client,
                            status: :waiting_payment_aproval)
    order2 = create(:order, order_code: '458665', client: client, status: 0)
    create(:product, order: order1, client: client, status: :canceled)
    create(:product, order: order2, name: 'host', group: 'HOSP', plan: 'Hospedagem Básica',
                     frequency: 'Anual', price: '350', client: client, status: 0)
    result = [order1, order2]
    allow(Order).to receive(:pull_orders).and_return(result)
    response_cancel = Faraday::Response.new(status: 200, response_body: [])
    allow(Faraday).to receive(:patch).with("#{ApisDomains.sales}/api/v1/orders/#{order2.order_code}/canceled")
                                     .and_return(response_cancel)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Pendentes', from: 'status'
    click_on 'Filtrar'
    within("tr##{order2.order_code}") do
      click_on 'Cancelar Pedido'
    end
    expect(page).to have_content 'Pedido cancelado com sucesso'
    within("td##{order2.order_code}") do
      expect(page).to have_content 'Cancelado'
    end
    within("td##{order2.product.id}")
    expect(page).to have_content 'Cancelado'
  end
  it 'e falha' do
    client = create(:client)
    order1 = create(:order, order_code: '201546', client: client,
                            status: :waiting_payment_aproval)
    order2 = create(:order, order_code: '458665', client: client, status: :pending)
    create(:product, order: order1, client: client, status: :canceled)
    create(:product, order: order2, name: 'host', group: 'HOSP', plan: 'Hospedagem Básica',
                     frequency: 'Anual', price: '350', client: client, status: 0)

    response_cancel = Faraday::Response.new(status: 406, response_body: [])
    allow(Faraday).to receive(:patch).with("#{ApisDomains.sales}/api/v1/orders/#{order2.order_code}/canceled")
                                     .and_return(response_cancel)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Pendentes', from: 'status'
    click_on 'Filtrar'
    within("tr##{order2.order_code}") do
      click_on 'Cancelar Pedido'
    end

    expect(page).to have_content 'Falha ao cancelar o pedido, tente novamente mais tarde!'
    within("tr##{order2.order_code}") do
      expect(page).to have_content 'Pendente'
    end
  end
end
