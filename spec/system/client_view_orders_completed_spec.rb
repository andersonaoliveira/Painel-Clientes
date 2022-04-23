require 'rails_helper'

describe 'Cliente visualiza pedidos finalizados' do
  it 'a partir de um link no painel de clientes' do
    client = create(:client)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Finalizados', from: 'status'
    click_on 'Filtrar'

    expect(current_path).to eq orders_path
    expect(page).to have_css('h1', text: 'Pedidos')
  end

  it 'e não tem pedidos finalizados' do
    client = create(:client)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Finalizados', from: 'status'
    click_on 'Filtrar'

    expect(current_path).to eq orders_path
    expect(page).to have_content('Não há pedidos a serem exibidos')
  end

  it 'e exibe pedidos finalizados' do
    client = create(:client)
    order1 = create(:order, order_code: '201546', client: client, status: :completed)
    order2 = create(:order, order_code: '458665', client: client, status: :completed)
    create(:product, order: order1, client: client, status: :paid)
    create(:product, order: order2, name: 'host', group: 'HOSP', plan: 'Hospedagem Básica',
                     frequency: 'Anual', price: '350', client: client, status: :paid)
    result = [order1, order2]
    allow(Order).to receive(:pull_orders).and_return(result)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Finalizados', from: 'status'
    click_on 'Filtrar'

    expect(current_path).to eq orders_path
    expect(page).to have_css('h1', text: 'Pedidos')
    expect(page).to have_content('201546')
    expect(page).to have_content('mail marketing')
    expect(page).to have_content('Marketing')
    expect(page).to have_content('250,00')
    expect(page).to have_content('458665')
    expect(page).to have_content('host')
    expect(page).to have_content('Hospedagem Básica')
    expect(page).to have_content('350,00')
  end
end
