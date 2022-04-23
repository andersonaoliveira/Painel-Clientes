require 'rails_helper'

describe 'Cliente visualizada detalhes do pedido' do
  it 'e não acessa formulário diretamente quando não logado' do
    visit order_path(1)

    expect(current_path).to eq new_client_session_path
  end

  it 'e vê dados do pedido' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'

    expect(current_path).to eq order_path(order.id)
    expect(page).to have_css('h1', text: 'Dados do Pedido')
    expect(page).to have_css('th', text: 'Produto')
    expect(page).to have_css('td', text: 'mail marketing')
    expect(page).to have_css('th', text: 'Status do Produto')
    expect(page).to have_css('th', text: 'Plano')
    expect(page).to have_css('td', text: 'Anual')
    expect(page).to have_css('th', text: 'Valor')
    expect(page).to have_css('td', text: '250,00')
    expect(page).to have_css('th', text: 'Status do Pedido')
    expect(page).to have_css('td', text: 'Pendente')
  end
  it 'e vê opões de pagamento do pedido pendente' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'

    expect(current_path).to eq order_path(order.id)
    expect(page).to have_css('h2', text: 'Pagamento de Pedido')
    expect(page).to have_css('div', text: 'Cartão de Crédito')
    expect(page).to have_css('div', text: 'Opções de parcelamento')
    expect(page).to have_css('div', text: 'Cupom de Desconto')
  end
  it 'e não vê opões de pagamento do pedido cancelado' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client, status: :canceled)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'

    expect(current_path).to eq order_path(order.id)
    expect(page).not_to have_css('h2', text: 'Pagamento de Pedido')
    expect(page).not_to have_css('div', text: 'Cartão de Crédito')
    expect(page).not_to have_css('div', text: 'Opções de parcelamento')
    expect(page).not_to have_css('div', text: 'Cupom de Desconto')
  end
end
