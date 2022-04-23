require 'rails_helper'

describe 'Cliente visualiza produtos pagos' do
  it 'Cliente precisa estar logado' do
    visit products_path

    expect(current_path).to eq new_client_session_path
  end

  it 'Com sucesso' do
    client = create(:client)
    p1 = create(:product, name: 'mail marketing', plan: 'Marketing', status: :waiting_payment, client: client)
    p2 = create(:product, name: 'host', plan: 'Hospedagem Básica', status: :paid, client: client)
    params2 = JSON.generate({ customer: client.eni, product_code: p2.generate_code, plan_id: p2.order.plan_id })
    p3 = create(:product, name: 'email', plan: 'email', status: :installing, client: client)
    params3 = JSON.generate({ customer: client.eni, product_code: p3.generate_code, plan_id: p3.order.plan_id })

    response2 = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    response3 = Faraday::Response.new(status: 500, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params2,
                                          'Content-Type' => 'application/json')
                                    .and_return(response2)
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params3,
                                          'Content-Type' => 'application/json')
                                    .and_return(response3)

    p1.install
    p2.install
    p3.install

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'

    expect(current_path).to eq products_path
    within('table#actives') do
      within('thead') do
        expect(page).to have_css('th', text: 'Nome')
        expect(page).to have_css('th', text: 'Plano')
        expect(page).to have_css('th', text: 'Status')
      end
      within('tbody') do
        within("tr##{p2.id}") do
          expect(page).to have_css('td', text: 'host')
          expect(page).to have_css('td', text: 'Hospedagem Básica')
          expect(page).to have_css('td', text: 'Instalado')
        end
        within("tr##{p3.id}") do
          expect(page).to have_css('td', text: 'email')
          expect(page).to have_css('td', text: 'email')
          expect(page).to have_css('td', text: 'Instalando')
        end
      end
    end
  end

  context 'Mas não possui nenhum produto' do
    it 'e vê um aviso' do
      client = Client.create!(name: 'Andrei', email: 'andrei@func.locaweb.com.br',
                              eni: '57896321491', password: '123456')

      login_as(client, scope: :client)
      visit root_path

      click_on 'Produtos'

      expect(page).to have_css('h1', text: 'Produtos')
      expect(page).to have_css('h3', text: 'Você não possui nenhum produto')
      expect(page).to have_css('p', text: 'Clique AQUI para visualizar seus pedidos pendentes')
    end

    it 'e vai para a pagina de pedidos pendentes' do
      client = Client.create!(name: 'Andrei', email: 'andrei@func.locaweb.com.br',
                              eni: '57896321491', password: '123456')
      orders = []
      allow(Order).to receive(:pull_orders).and_return(orders)
      login_as(client, scope: :client)
      visit root_path

      click_on 'Produtos'
      click_on 'AQUI'

      expect(current_path).to eq orders_path
    end
  end

  it 'E pode retornar para o início' do
    client = Client.create!(name: 'Andrei', email: 'andrei@func.locaweb.com.br',
                            eni: '57896321491', password: '123456')

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    click_on 'Início'

    expect(current_path).to eq root_path
  end

  it 'E pode acessar detalhes de um produto' do
    client = create(:client)
    p1 = create(:product, name: 'host', plan: 'Hospedagem Básica', status: :paid, client: client)
    p2 = create(:product, name: 'email', plan: 'email', status: :installing, client: client)
    params1 = JSON.generate({ customer: client.eni, product_code: p1.generate_code, plan_id: p1.order.plan_id })
    params2 = JSON.generate({ customer: client.eni, product_code: p2.generate_code, plan_id: p2.order.plan_id })
    response1 = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    response2 = Faraday::Response.new(status: 500, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params1,
                                          'Content-Type' => 'application/json')
                                    .and_return(response1)
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params2,
                                          'Content-Type' => 'application/json')
                                    .and_return(response2)
    p1.install
    p2.install

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'
    within("tr##{p1.id}") do
      click_on 'Detalhes'
    end

    expect(current_path).to eq product_path(p1)
    expect(page).to have_content('host')
    expect(page).not_to have_content('email')
  end

  it 'Produtos cancelados aparecem em uma tabela separada' do
    client = create(:client)
    p1 = create(:product, name: 'email', plan: 'email', status: :paid, client: client)
    p2 = create(:product, name: 'host', plan: 'Hospedagem Básica', status: :paid, client: client)
    params1 = JSON.generate({ customer: client.eni, product_code: p1.generate_code, plan_id: p1.order.plan_id })
    params2 = JSON.generate({ customer: client.eni, product_code: p2.generate_code, plan_id: p2.order.plan_id })
    response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params1,
                                          'Content-Type' => 'application/json')
                                    .and_return(response)
    allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params2,
                                          'Content-Type' => 'application/json')
                                    .and_return(response)

    p1.install
    p2.install
    response_cancel = Faraday::Response.new(status: 201, response_body: [])
    # rubocop:disable Layout/LineLength
    allow(Faraday).to receive(:patch).with("#{ApisDomains.products}/api/v1/customer_product/installations/#{p2.code}/inactive")
                                     .and_return(response_cancel)
    # rubocop:enable Layout/LineLength
    p2.cancel

    login_as(client, scope: :client)
    visit root_path
    click_on 'Produtos'

    expect(current_path).to eq products_path
    within('table#cancelled') do
      within('thead') do
        expect(page).to have_css('th', text: 'Nome')
        expect(page).to have_css('th', text: 'Plano')
        expect(page).to have_css('th', text: 'Status')
      end
      within('tbody') do
        within("tr##{p2.id}") do
          expect(page).to have_css('td', text: 'host')
          expect(page).to have_css('td', text: 'Hospedagem Básica')
          expect(page).to have_css('td', text: 'Cancelado')
        end
      end
      expect(page).not_to have_css('td', text: 'mail marketing')
      expect(page).not_to have_css('td', text: 'Marketing')
      expect(page).not_to have_css('td', text: 'Instalado')
    end
    within('table#actives') do
      expect(page).not_to have_css('td', text: 'host')
      expect(page).not_to have_css('td', text: 'Hospedagem Básica')
      expect(page).not_to have_css('td', text: 'Cancelado')
    end
  end
end
