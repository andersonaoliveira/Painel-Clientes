require 'rails_helper'

RSpec.describe Order, type: :model do
  context 'pull_orders' do
    it 'salva pedidos com sucesso' do
      client = create(:client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)
      Order.pull_orders(client.eni)

      result = Order.all

      expect(result.length).to eq 2
      expect(result[0].order_code).to eq '3'
      expect(result[1].order_code).to eq '6'
      expect(result[0].client_id).to eq client.id
      expect(result[0].product).not_to be_nil
      expect(result[1].client_id).to eq client.id
      expect(result[1].product).not_to be_nil
    end

    it 'não salva pedidos repetidos' do
      client = create(:client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'repeted_orders.json'))
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)
      Order.pull_orders(client.eni)

      result = Order.all

      expect(result.length).to eq 1
      expect(result[0].order_code).to eq '3'
      expect(result[0].client_id).to eq client.id
      expect(result[0].product).not_to be_nil
    end
  end

  context 'Monta o produto a partir do pedido' do
    it 'com sucesso' do
      client = create(:client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)

      Order.pull_orders(client.eni)

      result = Product.all

      expect(result[0].order.order_code).to eq '3'
      expect(result[1].order.order_code).to eq '6'
      expect(result[0].status).to eq 'waiting_payment'
      expect(result[1].status).to eq 'waiting_payment'
      expect(result[0].name).to eq 'Hospedagem'
      expect(result[1].name).to eq 'Hospedagem'
      expect(result[0].plan).to eq 'Hospedagem Básica'
      expect(result[1].plan).to eq 'Hospedagem Básica'
      expect(result[0].code).to be_nil
      expect(result[1].code).to be_nil
    end

    it 'mas api de produtos esta fora do ar' do
      client = create(:client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 500, response_body: '{}')
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)

      Order.pull_orders(client.eni)

      result = Order.all

      expect(result.length).to eq 2
      expect(result[0].plan_id).to eq 1
      expect(result[1].plan_id).to eq 1
      expect(result[0].product).to be_nil
      expect(result[1].product).to be_nil
    end
    it 'pedido já existe' do
      client = create(:client)
      create(:order, order_code: 3, client: client)
      orders_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'orders.json'))
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_sell = Faraday::Response.new(status: 200, response_body: orders_data)
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.sales}/api/v1/orders/clients/#{client.eni}")
                                     .and_return(response_sell)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)

      Order.pull_orders(client.eni)

      result = Product.all

      expect(result[0].order.order_code).to eq '3'
      expect(result[1].order.order_code).to eq '6'
      expect(result[0].status).to eq 'waiting_payment'
      expect(result[1].status).to eq 'waiting_payment'
      expect(result[0].name).to eq 'Hospedagem'
      expect(result[1].name).to eq 'Hospedagem'
      expect(result[0].plan).to eq 'Hospedagem Básica'
      expect(result[1].plan).to eq 'Hospedagem Básica'
    end
  end

  it 'cancela pedido pendente' do
    client = create(:client)
    order = create(:order, order_code: '458665', client: client, status: :pending)
    response_cancel = Faraday::Response.new(status: 200, response_body: [])
    allow(Faraday).to receive(:patch).with("#{ApisDomains.sales}/api/v1/orders/#{order.order_code}/canceled")
                                     .and_return(response_cancel)
    order.cancel

    expect(order.status).to eq 'canceled'
  end
  it 'tenta cancelar e falha' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client,
                           status: :pending)
    response_cancel = Faraday::Response.new(status: 406, response_body: [])
    allow(Faraday).to receive(:patch).with("#{ApisDomains.sales}/api/v1/orders/#{order.order_code}/canceled")
                                     .and_return(response_cancel)
    order.cancel

    expect(order.status).not_to eq 'canceled'
  end
  it 'tenta cancelar um pedido que não está pendente' do
    client = create(:client)
    order = create(:order, order_code: '201546', client: client, status: :completed)
    create(:product, name: 'host', group: 'HOSP', plan: 'Hospedagem Básica', order: order,
                     frequency: 'Anual', price: '350', client: client, status: :canceled)
    response_cancel = Faraday::Response.new(status: 402, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.sales}/api/v1/order_cancel", order.as_json,
                                          'Content-Type' => 'application/json')
                                    .and_return(response_cancel)
    order.cancel

    expect(order.status).not_to eq 'canceled'
  end
  context '.payment_order' do
    it 'envia informações de pagamento com sucesso' do
      client = create(:client)
      order = create(:order, order_code: '201546', client: client, status: :pending)
      create(:product, client: client, status: :waiting_payment, order: order)
      params = { 'order_code' => '201546', 'token' => '001', 'installment' => 2, 'cupom' => nil,
                 'client_eni' => '33256256870', 'product_group_id' => 1 }
      response = Faraday::Response.new(status: 201, response_body: [])
      allow(Product).to receive(:find_group_id).and_return(1)
      allow(Faraday).to receive(:post).and_return(response)

      Order.payment_order(params)
      result = Order.find(order.id)

      expect(result.status).to eq 'waiting_payment_aproval'
    end
    it 'envia informações de pagamento e falha na conexão' do
      client = create(:client)
      order = create(:order, order_code: '201546', client: client, status: :pending)
      create(:product, client: client, status: :waiting_payment, order: order)
      params = { 'order_code' => '201546', 'token' => '001', 'installment' => 2, 'cupom' => nil,
                 'client_eni' => '33256256870', 'product_group_id' => 1 }
      response = Faraday::Response.new(status: 500, response_body: [])
      allow(Faraday).to receive(:post).and_return(response)

      result1 = Order.payment_order(params)
      result2 = Order.find(order.id)

      expect(result1).to eq nil
      expect(result2.status).to eq 'pending'
    end
    it 'envia informações de pagamento e retorna erros' do
      client = create(:client)
      order = create(:order, order_code: '201546', client: client, status: :pending)
      create(:product, client: client, status: :waiting_payment, order: order)
      response = Faraday::Response.new(status: 406, response_body: '{ "errors": "Cartão de Crédito inválido" }')
      allow(Faraday).to receive(:post).and_return(response)

      result1 = Order.find(order.id)
      result2 = Order.response_payment(response, order)

      expect(result1.status).to eq 'pending'
      expect(result2).to eq 'errors' => 'Cartão de Crédito inválido'
    end
  end
end
