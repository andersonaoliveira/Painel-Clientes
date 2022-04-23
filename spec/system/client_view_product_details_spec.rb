require 'rails_helper'

describe 'Usuario visualiza os detalhes de um pedido' do
  it 'Precisa estar logado' do
    client = create(:client)
    product = create(:product, status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(response)
    product.install

    visit product_path(product.id)

    expect(current_path).to eq new_client_session_path
  end

  it 'Só é permitido visualizar produtos do próprio usuario' do
    client1 = create(:client, email: 'andrei@campus.com.br', eni: '57896321491')
    client2 = create(:client, email: 'anderson@campus.com.br', eni: '57896321419')
    product = create(:product, status: :paid, client: client1)
    params = JSON.generate({ customer: client1.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(response)
    product.install

    login_as(client2, scope: :client)
    visit product_path(product.id)

    expect(current_path).to eq root_path
    expect(page).to have_content('Você não tem autorização para acessar esta página')
  end

  it 'com sucesso' do
    client = create(:client)
    product = create(:product, name: 'mail marketing', group: 'HOSP', plan: 'Marketing básico',
                               frequency: 'Anual', price: '250', status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(response)
    product.install

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    within("tr##{product.id}") do
      click_on 'Detalhes'
    end

    expect(page).to have_css('h1', text: 'mail marketing')
    expect(page).to have_css('strong', text: 'Instalado')
    expect(page).to have_css('span', text: 'Grupo')
    expect(page).to have_css('strong', text: 'HOSP')
    expect(page).to have_css('span', text: 'Plano')
    expect(page).to have_css('strong', text: 'Marketing básico')
    expect(page).to have_css('span', text: 'Periodicidade')
    expect(page).to have_css('strong', text: 'Anual')
    expect(page).to have_css('span', text: 'Preço')
    expect(page).to have_css('strong', text: 'R$ 250,00')
    expect(page).to have_css('span', text: 'Servidor de instalação')
    expect(page).to have_css('strong', text: 'SRAP')
  end

  it 'Mas o produto ainda não foi instalado completamente' do
    client = create(:client)
    product = create(:product, name: 'mail marketing', status: :paid, client: client)
    params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                             plan_id: product.order.plan_id })
    response = Faraday::Response.new(status: 500, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                          'Content-Type' => 'application/json')
                                    .and_return(response)
    product.install

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    within("tr##{product.id}") do
      click_on 'Detalhes'
    end

    expect(page).to have_css('h1', text: 'mail marketing')
    expect(page).to have_css('strong', text: 'Instalando')
    expect(page).to have_css('span', text: 'Servidor de instalação')
    expect(page).to have_css('strong', text: 'Aguardando')
  end

  context 'e é feita uma nova chamada pelo servidor' do
    it 'com sucesso' do
      client = create(:client)
      product = create(:product, status: :paid, client: client)
      params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                               plan_id: product.order.plan_id })
      response1 = Faraday::Response.new(status: 500, response_body: [])
      response2 = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(response1)
      product.install
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(response2)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/periods").and_return(true)

      login_as(client, scope: :client)
      visit root_path
      click_on 'Produtos'
      within("tr##{product.id}") do
        click_on 'Detalhes'
      end

      expect(product.id).to eq 1
      expect(page).to have_content('Instalado')
    end

    it 'mas produtos está fora dor ar' do
      client = create(:client)
      product = create(:product, status: :paid, client: client)
      params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                               plan_id: product.order.plan_id })
      response1 = Faraday::Response.new(status: 500, response_body: [])
      response2 = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(response1)
      product.install
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(response2)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/periods").and_raise('ERRO')

      login_as(client, scope: :client)
      visit root_path
      click_on 'Produtos'
      within("tr##{product.id}") do
        click_on 'Detalhes'
      end

      expect(product.id).to eq 1
      expect(page).to have_content('Instalando')
    end
  end

  context 'e cancela o produto' do
    it 'com sucesso' do
      client = create(:client)
      product = create(:product, status: :paid, client: client)
      params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                               plan_id: product.order.plan_id })
      response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(response)
      product.install
      response_cancel = Faraday::Response.new(status: 201, response_body: [])
      # rubocop:disable Layout/LineLength
      allow(Faraday).to receive(:patch).with("#{ApisDomains.products}/api/v1/customer_product/installations/#{product.code}/inactive")
                                       .and_return(response_cancel)
      # rubocop:enable Layout/LineLength

      login_as(client, scope: :client)
      visit root_path
      click_on 'Produtos'
      within("tr##{product.id}") do
        click_on 'Detalhes'
      end
      click_on 'Cancelar'

      expect(page).to have_content('Produto cancelado com sucesso')
      expect(page).to have_content('Cancelado')
    end

    it 'mas não cominica com a api de produtos' do
      client = create(:client)
      product = create(:product, status: :paid, client: client)
      params = JSON.generate({ customer: client.eni, product_code: product.generate_code,
                               plan_id: product.order.plan_id })
      response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(response)
      product.install
      response_cancel = Faraday::Response.new(status: 500, response_body: [])
      # rubocop:disable Layout/LineLength
      allow(Faraday).to receive(:patch).with("#{ApisDomains.products}/api/v1/customer_product/installations/#{product.code}/inactive")
                                       .and_return(response_cancel)
      # rubocop:enable Layout/LineLength

      login_as(client, scope: :client)
      visit root_path
      click_on 'Produtos'
      within("tr##{product.id}") do
        click_on 'Detalhes'
      end
      click_on 'Cancelar'

      expect(page).to have_css('div.alert', text: 'Falha ao cancelar o produto, tente novamente mais tarde!')
      expect(page).to have_content('Instalado')
    end
  end
end
