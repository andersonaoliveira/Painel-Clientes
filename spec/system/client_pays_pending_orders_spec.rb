require 'rails_helper'

describe 'cliente finaliza pedido pendente' do
  it 'não acessa formulário diretamente não estando logado' do
    visit orders_path

    expect(current_path).to eq new_client_session_path
  end

  it 'e vê formulário de pagamento' do
    client = create(:client)
    order = create(:order, client: client, order_code: '201546')
    create(:product, order: order, client: client)
    orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
    plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
    response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
    response_product = Faraday::Response.new(status: 200, response_body: plan_data)
    allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                   .and_return(response_sell)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                   .and_return(response_product)
    allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

    create(:credit_card, client: client)
    create(:credit_card, token: 'jc6LW7mEOUiBT8y9KgW6', nickname: 'Meu Inter', client: client)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'

    expect(page).to have_css('h1', text: 'Dados do Pedido')
    expect(page).to have_css('select#card_banner')
    expect(page).to have_css('select#instalments_select')
    expect(page).to have_field('Cupom')
    expect(page).to have_button('Efetuar Pagamento')
  end

  it 'cliente não preenche campos obrigatórios' do
    client = create(:client)
    order = create(:order, client: client, order_code: '201546')
    create(:product, order: order, client: client)
    orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
    plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
    response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
    response_product = Faraday::Response.new(status: 200, response_body: plan_data)
    allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                   .and_return(response_sell)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                   .and_return(response_product)
    data = { 'client_eni' => '33256256870', 'cupom' => '20%', 'group' => 'MAIL', 'installment' => '',
             'order_code' => '201546', 'price' => '250', 'token' => '' }
    allow(Order).to receive(:payment_order)
      .with(data).and_return('errors' => ['Cartão de Crédito não pode ficar em branco'])
    allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'
    fill_in 'Cupom',	with: '20%'
    click_on 'Efetuar Pagamento'

    expect(current_path).to eq pay_order_path(order)
    expect(page).to have_content('Cartão de Crédito não pode ficar em branco')
  end

  it 'com sucesso', js: true do
    client = create(:client)
    order = create(:order, client: client, order_code: '201546')
    create(:product, order: order, client: client)
    orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
    plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
    response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
    response_product = Faraday::Response.new(status: 200, response_body: plan_data)
    allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                   .and_return(response_sell)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                   .and_return(response_product)
    credit_card = create(:credit_card, client: client, card_banner_id: 1)
    create(:credit_card, client_id: client.id, nickname: 'Meu Inter Digital', token: 'mgKY3ej4HMrNnjAMb3zD')
    data = { 'client_eni' => '33256256870', 'cupom' => '20%', 'group' => 'MAIL', 'installment' => '2',
             'order_code' => '201546', 'price' => '250', 'token' => credit_card.token }
    allow(Order).to receive(:payment_order).with(data)
                                           .and_return('success' => ['Pagamento aguardando aprovação'])
    response_instalments = Faraday::Response.new(status: 200, response_body: '{"max_instalments": "5"}')
    allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/#{credit_card.card_banner_id}")
                                   .and_return(response_instalments)
    allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'
    find('#card_banner').select('Meu Nubank')
    find('#instalments_select').select('2x de R$ 125.00')
    fill_in 'Cupom',	with: '20%'
    click_on 'Efetuar Pagamento'

    expect(page).to have_content('Pagamento aguardando aprovação')
  end

  it 'cupom não é válido', js: true do
    client = create(:client)
    order = create(:order, client: client, order_code: '201546')
    create(:product, order: order, client: client)
    orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
    plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
    response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
    response_product = Faraday::Response.new(status: 200, response_body: plan_data)
    allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                   .and_return(response_sell)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                   .and_return(response_product)
    credit_card = create(:credit_card, client: client, card_banner_id: 1)
    create(:credit_card, client_id: client.id, nickname: 'Meu Inter Digital', token: 'mgKY3ej4HMrNnjAMb3zD')
    data = { 'client_eni' => '33256256870', 'cupom' => '20%', 'group' => 'MAIL', 'installment' => '2',
             'order_code' => '201546', 'price' => '250', 'token' => credit_card.token }
    allow(Order).to receive(:payment_order).with(data).and_return('errors' => ['Cupom Inválido'])
    response_instalments = Faraday::Response.new(status: 200, response_body: '{"max_instalments": "5"}')
    allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/#{credit_card.card_banner_id}")
                                   .and_return(response_instalments)
    allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'
    find('#card_banner').select('Meu Nubank')
    find('#instalments_select').select('2x de R$ 125.00')
    fill_in 'Cupom',	with: '20%'
    click_on 'Efetuar Pagamento'

    expect(current_path).to eq pay_order_path(order)
    expect(page).to have_content('Cupom Inválido')
  end

  context 'e o pagamento é recusado', js: true do
    it 'e cartão de crédito está vencido' do
      client = create(:client)
      order = create(:order, client: client, order_code: '201546')
      create(:product, order: order, client: client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)
      credit_card = create(:credit_card, client: client, card_banner_id: 1)
      create(:credit_card, client_id: client.id, nickname: 'Meu Inter Digital', token: 'mgKY3ej4HMrNnjAMb3zD')
      data = { 'client_eni' => '33256256870', 'cupom' => '20%', 'group' => 'MAIL', 'installment' => '2',
               'order_code' => '201546', 'price' => '250', 'token' => credit_card.token }
      allow(Order).to receive(:payment_order).with(data).and_return('errors' => ['Cartão de Crédito Inválido'])
      response_instalments = Faraday::Response.new(status: 200, response_body: '{"max_instalments": "5"}')
      allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/#{credit_card.card_banner_id}")
                                     .and_return(response_instalments)
      allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

      login_as(client, scope: :client)
      visit root_path
      click_on 'Pedidos'
      click_on '201546'
      find('#card_banner').select('Meu Nubank')
      find('#instalments_select').select('2x de R$ 125.00')
      fill_in 'Cupom',	with: '20%'
      click_on 'Efetuar Pagamento'

      expect(current_path).to eq pay_order_path(order)
      expect(page).to have_content('Cartão de Crédito Inválido')
    end

    it 'e pedido já venceu' do
      client = create(:client)
      order = create(:order, client: client, order_code: '201546')
      create(:product, order: order, client: client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)
      credit_card = create(:credit_card, client: client, card_banner_id: 1)
      create(:credit_card, client_id: client.id, nickname: 'Meu Inter Digital', token: 'mgKY3ej4HMrNnjAMb3zD')
      data = { 'client_eni' => '33256256870', 'cupom' => '20%', 'group' => 'MAIL', 'installment' => '2',
               'order_code' => '201546', 'price' => '250', 'token' => credit_card.token }
      allow(Order).to receive(:payment_order).with(data).and_return('errors' => ['Pedido já vencido'])
      response_instalments = Faraday::Response.new(status: 200, response_body: '{"max_instalments": "5"}')
      allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/#{credit_card.card_banner_id}")
                                     .and_return(response_instalments)
      allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

      login_as(client, scope: :client)
      visit root_path
      click_on 'Pedidos'
      click_on '201546'
      find('#card_banner').select('Meu Nubank')
      find('#instalments_select').select('2x de R$ 125.00')
      fill_in 'Cupom',	with: '20%'
      click_on 'Efetuar Pagamento'

      expect(current_path).to eq pay_order_path(order)
      expect(page).to have_content('Pedido já vencido')
    end
  end

  it 'e retorna mensagem de erro quando API não está disponível', js: true do
    client = create(:client)
    order = create(:order, client: client, order_code: '201546')
    create(:product, order: order, client: client)
    orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
    plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
    response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
    response_product = Faraday::Response.new(status: 200, response_body: plan_data)
    allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                   .and_return(response_sell)
    allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                   .and_return(response_product)
    credit_card = create(:credit_card, client: client, card_banner_id: 1)
    create(:credit_card, client_id: client.id, nickname: 'Meu Inter Digital', token: 'mgKY3ej4HMrNnjAMb3zD')
    data = { 'client_eni' => '33256256870', 'cupom' => '20%', 'group' => 'MAIL', 'installment' => '2',
             'order_code' => '201546', 'price' => '250', 'token' => credit_card.token }
    allow(Order).to receive(:payment_order).with(data).and_return('Não foi possível efetuar pagamento no momento')
    response_instalments = Faraday::Response.new(status: 200, response_body: '{"max_instalments": "5"}')
    allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/#{credit_card.card_banner_id}")
                                   .and_return(response_instalments)
    allow_any_instance_of(OrdersController).to receive(:check_payment_status).and_return(true)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Pedidos'
    click_on '201546'
    find('#card_banner').select('Meu Nubank')
    find('#instalments_select').select('2x de R$ 125.00')
    fill_in 'Cupom',	with: '20%'
    click_on 'Efetuar Pagamento'

    expect(current_path).to eq pay_order_path(order)
    expect(page).to have_content('Não foi possível efetuar pagamento no momento')
  end
end
