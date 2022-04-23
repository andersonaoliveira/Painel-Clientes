require 'rails_helper'

describe 'Admin vê tela de clientes' do
  context 'Precisa ser adm para acessar' do
    it 'Cliente logado não consegue acessar' do
      cliente = create(:client)

      login_as(cliente, scope: :client)
      visit admin_clients_path

      expect(current_path).to eq root_path
    end

    it 'Visitante não consegue logar' do
      visit admin_clients_path

      expect(current_path).to eq root_path
    end
  end

  it 'Com sucesso' do
    admin = create(:admin)
    client1 = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
    client2 = create(:client, name: 'João Silva', email: 'js@mail.com', eni: '00000000002')
    p1 = create(:product, client: client1, status: :paid)
    p2 = create(:product, client: client1, status: :paid)
    create(:product, client: client1, status: :waiting_payment)
    p3 = create(:product, client: client2, status: :paid)
    create(:product, client: client2, status: :waiting_payment)
    create(:product, client: client2, status: :waiting_payment)
    create(:product, client: client2, status: :waiting_payment)
    response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
    allow(Faraday).to receive(:post).and_return(response)
    p1.install
    p2.install
    p3.install

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Clientes'

    within('table') do
      within('thead') do
        expect(page).to have_css('th', text: 'Nome')
        expect(page).to have_css('th', text: 'Email')
        expect(page).to have_css('th', text: 'Documento')
        expect(page).to have_css('th', text: 'Nº de pedidos')
        expect(page).to have_css('th', text: 'Nº de produtos instalados')
      end
      within('tbody') do
        within("tr##{client1.eni}") do
          expect(page).to have_css('td', text: 'Pedro de Solsa')
          expect(page).to have_css('td', text: 'ps@mail.com')
          expect(page).to have_css('td', text: '00000000001')
          expect(page).to have_css('td', text: '3')
          expect(page).to have_css('td', text: '2')
          expect(page).to have_link('Detalhes', href: admin_client_path(client1.id))
        end
        within("tr##{client2.eni}") do
          expect(page).to have_css('td', text: 'João Silva')
          expect(page).to have_css('td', text: 'js@mail.com')
          expect(page).to have_css('td', text: '00000000002')
          expect(page).to have_css('td', text: '4')
          expect(page).to have_css('td', text: '1')
          expect(page).to have_link('Detalhes', href: admin_client_path(client2.id))
        end
      end
    end
  end

  it 'Mas não tem nenhum cliente cadastrado' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Clientes'

    expect(page).to have_content('Não há clientes a serem exibidos')
  end

  context 'e acessa detalhes de um client' do
    it 'e ve as principais informações do client' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Clientes'
      within("tr##{client.eni}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h1', text: 'Pedro de Solsa')
      expect(page).to have_css('strong', text: 'ps@mail.com')
      expect(page).to have_css('strong', text: '00000000001')
    end

    it 'e ve a tabela de pedidos' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
      order1 = create(:order, client: client, order_code: '1a')
      order2 = create(:order, client: client, order_code: '2a')
      order3 = create(:order, client: client, order_code: '3a')
      p1 = create(:product, client: client, status: :paid, order: order1)
      p2 = create(:product, client: client, status: :paid, order: order2)
      create(:product, client: client, status: :waiting_payment, order: order3)
      response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).and_return(response)
      p1.install
      p2.install

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Clientes'
      within("tr##{client.eni}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h2', text: 'Pedidos')
      within('table#pedidos') do
        within('thead') do
          expect(page).to have_css('th', text: 'Código')
          expect(page).to have_css('th', text: 'Status')
        end
        within('tbody') do
          within('tr#1a') do
            expect(page).to have_css('td', text: '1a')
            expect(page).to have_css('td', text: 'Completo')
            expect(find_button('Cancelar', disabled: true)).not_to be_nil
          end
          within('tr#2a') do
            expect(page).to have_css('td', text: '2a')
            expect(page).to have_css('td', text: 'Completo')
            expect(find_button('Cancelar', disabled: true)).not_to be_nil
          end
          within('tr#3a') do
            expect(page).to have_css('td', text: '3a')
            expect(page).to have_css('td', text: 'Pendente')
            expect(find_button('Cancelar', disabled: false)).not_to be_nil
          end
        end
      end
    end

    it 'e ve a tabela de produtos' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
      p1 = create(:product, client: client, status: :paid)
      p2 = create(:product, client: client, status: :paid)
      p3 = create(:product, client: client, status: :waiting_payment)
      response = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).and_return(response)
      p1.install
      p2.install

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Clientes'
      within("tr##{client.eni}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h2', text: 'Produtos')
      within('table#produtos') do
        within('thead') do
          expect(page).to have_css('th', text: 'Nome')
          expect(page).to have_css('th', text: 'Código')
          expect(page).to have_css('th', text: 'Plano')
          expect(page).to have_css('th', text: 'Status')
        end
        within('tbody') do
          within("tr##{p1.id}") do
            expect(page).to have_css('td', text: 'mail marketing')
            expect(page).to have_css('td', text: p1.code)
            expect(page).to have_css('td', text: 'Marketing Básico')
            expect(page).to have_css('td', text: 'Instalado')
          end
          within("tr##{p2.id}") do
            expect(page).to have_css('td', text: 'mail marketing')
            expect(page).to have_css('td', text: p2.code)
            expect(page).to have_css('td', text: 'Marketing Básico')
            expect(page).to have_css('td', text: 'Instalado')
          end
          within("tr##{p3.id}") do
            expect(page).to have_css('td', text: 'mail marketing')
            expect(page).to have_css('td', text: '----------')
            expect(page).to have_css('td', text: 'Marketing Básico')
            expect(page).to have_css('td', text: 'Aguardando pagamento')
          end
        end
      end
    end
  end

  it 'Mas as apis estão fora do ar' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Clientes'

    # rubocop:disable Layout/LineLength
    expect(page).to have_css('div.alert', text: 'Falha ao atualizar clientes! Se algum cliente não aparecer, tente novamente mais tarde')
    # rubocop:enable Layout/LineLength
  end
end
