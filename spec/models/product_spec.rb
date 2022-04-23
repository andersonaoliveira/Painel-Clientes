require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'Produto é criado e recebe o código do servidor' do
    client = create(:client)
    product = create(:product, status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    resp = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(resp)
    product.install

    expect(product.code).not_to be_nil
    expect(product.server).not_to be_nil
    expect(client.products).to include product
  end

  it 'Produto é criado mas não recebe o código do servidor' do
    client = create(:client)
    product = create(:product, status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    resp = Faraday::Response.new(status: 500, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(resp)

    product.install

    expect(product.code).not_to be_nil
    expect(product.server).to be_nil
    expect(client.products).to include product
    expect(product.status).to eq 'installing'
  end

  it 'Produto não pode ser instalado com status "Aguardando pagamento"' do
    client = create(:client)
    product = create(:product, status: :waiting_payment, client: client)

    product.install

    expect(product.code).to be_nil
    expect(product.status).to eq 'waiting_payment'
    expect(client.products).to include product
  end

  it 'Produto instalado pode ser cancelado' do
    client = create(:client)
    product = create(:product, status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    resp = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(resp)
    product.install
    response_cancel = Faraday::Response.new(status: 201, response_body: [])
    # rubocop:disable Layout/LineLength
    allow(Faraday).to receive(:patch).with("#{ApisDomains.products}/api/v1/customer_product/installations/#{product.code}/inactive")
                                     .and_return(response_cancel)
    # rubocop:enable Layout/LineLength
    product.cancel

    expect(product.status).to eq 'canceled'
    expect(client.products).to include product
  end

  it 'Tenta cancelar mas não obtem respostas' do
    client = create(:client)
    product = create(:product, status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    resp = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(resp)
    product.install
    response_cancel = Faraday::Response.new(status: 500, response_body: [])
    # rubocop:disable Layout/LineLength
    allow(Faraday).to receive(:patch).with("#{ApisDomains.products}/api/v1/customer_product/installations/#{product.code}/inactive")
                                     .and_return(response_cancel)
    # rubocop:enable Layout/LineLength
    product.cancel

    expect(product.status).to eq 'installed'
  end

  it 'Checa se o usuario é o dono do produto' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com.br', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456')
    product = Product.new(name: 'Hospedagem web', group: 'HOSP', plan: 'Hospedagem Básica',
                          frequency: 'Anual', price: '350', client: client, status: :paid)
    client2 = Client.create!(name: 'Ruan', email: 'ruan@teste.com.br', eni: '00000000012',
                             address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                             birth_date: '16/03/1996', password: '11235853')

    expect(product.owner?(client)).to eq true
    expect(product.owner?(client2)).to eq false
  end
  context '.send_order' do
    it 'envia informações de pedido com sucesso' do
      client = create(:client, eni: '33256256870')
      create(:product, client: client)
      order_params = { 'client_eni' => '33256256870', 'plan_id' => '1' }
      response = Faraday::Response.new(status: 201, response_body: '{
                                                                      "id":1,
                                                                      "plan_id":1,
                                                                      "cupom_id":null,
                                                                      "client_id":1,
                                                                      "user_id":null,
                                                                      "status":"pending",
                                                                      "value":"50.0",
                                                                      "period":"Mensal",
                                                                      "client_eni":"33256256870"
                                                                    }')
      plan_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'product.json'))
      response_product = Faraday::Response.new(status: 200, response_body: plan_data)
      allow(Faraday).to receive(:post).and_return(response)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1")
                                     .and_return(response_product)

      result = Product.send_order(order_params, 50.0, 'Mensal')
      order = Order.last

      expect(result).not_to eq nil
      expect(result).not_to eq []
      expect(order.client.eni).to eq '33256256870'
      expect(order.product.name).to eq 'Hospedagem'
    end
  end

  context '.find_group_id' do
    it 'retorna group id de um produto' do
      product = create(:product)
      groups = JSON.generate([{ id: 1, name: 'Email', key: 'MAIL', description: 'Serviços de Email' },
                              { id: 2, name: 'Cloud', key: 'CLOUD',
                                description: 'Serviços de Armazenamento na Nuvem' }])
      response = Faraday::Response.new(status: 200, response_body: groups)
      allow(Faraday).to receive(:get).and_return(response)

      result = Product.find_group_id(product.group)

      expect(result).to eq 1
    end
  end
end
