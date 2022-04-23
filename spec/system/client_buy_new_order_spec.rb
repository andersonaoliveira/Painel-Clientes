require 'rails_helper'

describe 'cliente possui produto' do
  it 'e visualiza link de comprar novamente' do
    client = create(:client)
    create(:product, client: client, plan: 'Marketing básico', status: :installed)
    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    click_on 'Detalhes'

    expect(page).to have_link('Comprar Novamente')
  end

  it 'e vê formulário de compra' do
    client = create(:client)
    create(:product, client: client, plan: 'Marketing básico', status: :installed)
    plans = File.read(Rails.root.join('spec', 'support', 'api_resources', 'plans.json'))
    response = Faraday::Response.new(status: 200, response_body: plans)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans").and_return(response)
    frequencies = File.read(Rails.root.join('spec', 'support', 'api_resources', 'frequencies.json'))
    response2 = Faraday::Response.new(status: 200, response_body: frequencies)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/periods").and_return(response2)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    click_on 'Detalhes'
    click_on 'Comprar Novamente'

    expect(page).to have_css('h2', text: 'Comprar Novamente')
    expect(find_field('Produto', disabled: true)).not_to be_nil
    expect(page).to have_select('Plano')
  end

  it 'e visualiza opções de periodicidade no formulário de compra' do
    client = create(:client)
    create(:product, client: client, plan: 'Marketing básico', status: :installed, group: 'email')
    plan1 = Plan.new(id: 1, name: 'Marketing básico', group: 'email')
    plan2 = Plan.new(id: 2, name: 'E-mail mkt', group: 'email')
    plans = [plan1, plan2]
    allow(Plan).to receive(:all).and_return(plans)
    price1 = Price.new(id: 1, plan: plan1.name, value: 50, period: 'Anual')
    price2 = Price.new(id: 2, plan: plan1.name, value: 30, period: 'Semestral')
    prices = [price1, price2]
    allow(Price).to receive(:all).and_return(prices)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    click_on 'Detalhes'
    click_on 'Comprar Novamente'
    select 'Marketing básico', from: 'Plano'
    click_on 'Escolher Periodicidade'
    select 'Anual', from: 'Periodicidade'

    expect(page).to have_css('option', text: 'Anual')
    expect(find_field('Produto', with: 'Marketing básico', disabled: true)).not_to be_nil
  end

  it 'e compra novamente' do
    client = create(:client)
    create(:product, client: client, plan: 'Marketing básico', status: :installed, group: 'email')
    plan1 = Plan.new(id: 1, name: 'Marketing básico', group: 'email')
    plan2 = Plan.new(id: 2, name: 'E-mail mkt', group: 'email')
    plans = [plan1, plan2]
    allow(Plan).to receive(:all).and_return(plans)
    price1 = Price.new(id: 1, plan: plan1.name, value: 50, period: 'Anual')
    price2 = Price.new(id: 2, plan: plan1.name, value: 30, period: 'Semestral')
    prices = [price1, price2]
    allow(Price).to receive(:all).and_return(prices)
    allow(Product).to receive(:send_order).and_return({})
    order = build(:order, client: client)
    allow(Order).to receive(:pull_orders).and_return(order)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    click_on 'Detalhes'
    click_on 'Comprar Novamente'
    select 'Marketing básico', from: 'Plano'
    click_on 'Escolher Periodicidade'
    select 'Anual', from: 'Periodicidade'
    click_on 'Criar Pedido'

    expect(current_path).to eq orders_path
    expect(page).to have_content('Pedido criado com sucesso')
    expect(page).to have_css('td', text: 'mail marketing')
    expect(page).to have_css('td', text: 'Marketing básico')
  end

  it 'e retorna falha na hora na compra' do
    client = create(:client)
    product = create(:product, client: client, plan: 'Marketing básico', status: :installed, group: 'email')
    plan1 = Plan.new(id: 1, name: 'Marketing básico', group: 'email')
    plan2 = Plan.new(id: 2, name: 'E-mail mkt', group: 'email')
    plans = [plan1, plan2]
    allow(Plan).to receive(:all).and_return(plans)
    price1 = Price.new(id: 1, plan: plan1.name, value: 50, period: 'Anual')
    price2 = Price.new(id: 2, plan: plan1.name, value: 30, period: 'Semestral')
    prices = [price1, price2]
    allow(Price).to receive(:all).and_return(prices)
    allow(Product).to receive(:send_order).and_return(nil)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    click_on 'Detalhes'
    click_on 'Comprar Novamente'
    select 'Marketing básico', from: 'Plano'
    click_on 'Escolher Periodicidade'
    select 'Anual', from: 'Periodicidade'
    click_on 'Criar Pedido'

    expect(current_path).to eq product_path(product.id)
    expect(page).to have_content('Falha ao criar pedido, tente novamente mais tarde!')
  end
end
