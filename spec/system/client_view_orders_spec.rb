require 'rails_helper'

describe 'Cliente visualiza pedidos' do
  it 'visitante não acessa diretamente a tela de pedidos' do
    visit orders_path

    expect(current_path).to eq new_client_session_path
  end

  it 'a partir de um link no painel de clientes' do
    client = create(:client)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'

    expect(current_path).to eq orders_path
    expect(page).to have_css('h1', text: 'Pedidos')
    expect(page).to have_text('Status')
    expect(page).to have_content('Pendentes')
    expect(page).to have_content('Cancelados')
    expect(page).to have_content('Finalizados')
    expect(page).to have_content('Aguardando Aprovação')
    expect(page).to have_field('Status')
    expect(page).to have_button('Filtrar')
  end

  it 'só vez seus pedidos' do
    client = create(:client)
    client2 = create(:client, email: 'anderson@teste.com', eni: 578_963_214_91)
    order = create(:order, order_code: '201546', client: client)
    order2 = create(:order, order_code: '5555', client: client2)
    create(:product, order: order, client: client)
    create(:product, order: order, name: 'hospedagem', client: client2)
    orders = [order, order2]
    allow(Order).to receive(:pull_orders).and_return(orders)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'

    expect(current_path).to eq orders_path
    expect(page).to have_content 'mail marketing'
    expect(page).to have_content '201546'
    expect(page).not_to have_content 'hospedagem'
    expect(page).not_to have_content '5555'
  end

  it 'e não vê pedidos sem produto criado' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client)
    order2 = create(:order, order_code: '5555', client: client)
    create(:product, order: order, client: client)
    orders = [order, order2]
    allow(Order).to receive(:pull_orders).and_return(orders)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'

    expect(current_path).to eq orders_path
    expect(page).to have_content 'mail marketing'
    expect(page).to have_content '201546'
    expect(page).not_to have_content 'hospedagem'
    expect(page).not_to have_content '5555'
  end
end
