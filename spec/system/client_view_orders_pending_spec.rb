require 'rails_helper'

describe 'Cliente visualiza pedidos pendentes' do
  it 'a partir de um link no painel de clientes' do
    client = create(:client)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Pendentes', from: 'status'
    click_on 'Filtrar'

    expect(current_path).to eq orders_path
    expect(page).to have_css('h1', text: 'Pedidos')
  end

  it 'e recebe um erro' do
    client = create(:client)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_raise('Falha ao atualizar pedidos! Se seu pedido
                                                     não aparecer, tente novamente mais tarde')

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'

    expect(current_path).to eq orders_path
    expect(page).to have_content 'Falha ao atualizar pedidos! Se seu pedido não aparecer, tente novamente mais tarde'
  end

  it 'e não tem pedidos pendentes' do
    client = create(:client)
    order = create(:order, client: client, status: :canceled)
    create(:product, order: order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Pendentes', from: 'status'
    click_on 'Filtrar'

    expect(current_path).to eq orders_path
    expect(page).to have_content('Não há pedidos a serem exibidos')
  end

  it ' e exibe pedidos pendentes' do
    client = create(:client)
    order1 = create(:order, order_code: '201546', client: client, status: :pending)
    order2 = create(:order, order_code: '458665', client: client, status: :canceled)
    create(:product, order: order1, client: client, status: :canceled)
    create(:product, name: 'host', group: 'HOSP', plan: 'Hospedagem Básica', order: order2,
                     frequency: 'Anual', price: '350', client: client, status: :canceled)
    result = [order1, order2]
    allow(Order).to receive(:pull_orders).and_return(result)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    select 'Pendentes', from: 'status'
    click_on 'Filtrar'

    expect(current_path).to eq orders_path
    expect(page).to have_css('h1', text: 'Pedidos')
    expect(page).to have_content('201546')
    expect(page).to have_content('mail marketing')
    expect(page).to have_content('Marketing')
    expect(page).to have_content('250,00')
    expect(page).not_to have_content('458665')
    expect(page).not_to have_content('host')
    expect(page).not_to have_content('Hospedagem Básica')
    expect(page).not_to have_content('350,00')
  end
end
