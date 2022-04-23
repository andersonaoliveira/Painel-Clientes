require 'rails_helper'

describe 'Administrador acessa pagina de pedidos' do
  context 'Precisa ser adm para acessar' do
    it 'Cliente logado não consegue acessar' do
      cliente = create(:client)

      login_as(cliente, scope: :client)
      visit admin_orders_path

      expect(current_path).to eq root_path
    end

    it 'Visitante não consegue logar' do
      visit admin_orders_path

      expect(current_path).to eq root_path
    end
  end

  context 'E os pedidos são atualizados' do
    it 'Com sucesso' do
      admin = create(:admin)
      client = create(:client)
      allow(Order).to receive(:pull_orders).and_return(create(:order, order_code: '201546', client: client))

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Pedidos'

      within('tr#1') do
        expect(page).to have_css('td', text: '201546')
        expect(page).to have_css('td', text: 'Pendente')
        expect(page).to have_css('td', text: '33256256870')
      end
    end

    it 'Mas as apis estão fora do ar' do
      admin = create(:admin)
      allow(Order).to receive(:pull_orders).and_raise StandardError

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Pedidos'

      # rubocop:disable Layout/LineLength
      expect(page).to have_css('div.alert', text: 'Falha ao atualizar pedidos! Se algum pedido não aparecer, tente novamente mais tarde')
      # rubocop:enable Layout/LineLength
    end
  end

  it 'Com sucesso' do
    admin = create(:admin)
    client1 = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
    client2 = create(:client, name: 'João Silva', email: 'js@mail.com', eni: '00000000002')
    order1 = create(:order, client: client1, status: :paid)
    create(:product, client: client1, order: order1, name: 'Hospedagem linux')
    order2 = create(:order, client: client2, status: :completed)
    create(:product, client: client2, order: order2, name: 'Armazenamento em nuvem')
    order3 = create(:order, client: client2)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Pedidos'

    within('table') do
      within('thead') do
        expect(page).to have_css('th', text: 'Código')
        expect(page).to have_css('th', text: 'Status')
        expect(page).to have_css('th', text: 'Documento do cliente')
        expect(page).to have_css('th', text: 'Produto')
      end
      within('tbody') do
        within("tr##{order1.id}") do
          expect(page).to have_css('td', text: order1.order_code)
          expect(page).to have_css('td', text: 'Pago')
          expect(page).to have_css('td', text: '00000000001')
          expect(page).to have_css('td', text: 'Hospedagem linux')
        end
        within("tr##{order2.id}") do
          expect(page).to have_css('td', text: order2.order_code)
          expect(page).to have_css('td', text: 'Completo')
          expect(page).to have_css('td', text: '00000000002')
          expect(page).to have_css('td', text: 'Armazenamento em nuvem')
        end
        within("tr##{order3.id}") do
          expect(page).to have_css('td', text: order3.order_code)
          expect(page).to have_css('td', text: 'Pendente')
          expect(page).to have_css('td', text: '00000000002')
          expect(page).to have_css('td', text: '----------')
        end
      end
    end
  end

  it 'mas não tem nenhum pedido no sistema' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Pedidos'

    expect(page).to have_content('Não há pedidos a serem exibidos')
  end

  context 'e acessa detalhes de um produto' do
    it 'e ve os principais detalhes' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
      order = create(:order, order_code: 'aa', client: client, status: :completed)
      create(:product, name: 'Mail Marketing', order: order, client: client,
                       status: :installed, server: 'QYJKQMGKR9DIQDVMO54S', code: '36ZLGR9PWB')

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Pedidos'
      within("tr##{order.id}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h1', text: 'Mail Marketing')
      expect(page).to have_css('strong', text: 'aa')
      expect(page).to have_css('strong', text: 'Completo')
      expect(page).to have_css('strong', text: 'Marketing Básico')
      expect(page).to have_css('strong', text: 'Anual')
      expect(page).to have_css('strong', text: 'R$ 250,00')
      expect(page).to have_css('strong', text: 'Instalado')
      expect(page).to have_css('strong', text: '36ZLGR9PWB')
    end

    it 'e ve informações do client' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
      order = create(:order, order_code: 'aa', client: client, status: :completed)

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Pedidos'
      within("tr##{order.id}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h2', text: 'Pedro de Solsa')
      expect(page).to have_css('strong', text: 'ps@mail.com')
      expect(page).to have_css('strong', text: '00000000001')
      expect(page).to have_link('Detalhes', href: admin_client_path(client.id))
    end

    context 'e pode cancelar o pedido' do
      it 'com sucesso' do
        admin = create(:admin)
        client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
        order = create(:order, client: client)
        response_cancel = Faraday::Response.new(status: 200, response_body: [])
        allow(Faraday).to receive(:patch).with("#{ApisDomains.sales}/api/v1/orders/#{order.order_code}/canceled")
                                         .and_return(response_cancel)

        login_as(admin, scope: :admin)
        visit root_path
        click_on 'Pedidos'
        within("tr##{order.id}") do
          click_on 'Detalhes'
        end
        within('form.button_to') do
          click_on 'Cancelar'
        end

        expect(page).to have_css('strong', text: 'Cancelado')
      end

      it 'se estiver pendente' do
        admin = create(:admin)
        client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
        order = create(:order, client: client, status: :paid)

        login_as(admin, scope: :admin)
        visit root_path
        click_on 'Pedidos'
        within("tr##{order.id}") do
          click_on 'Detalhes'
        end

        expect(find('form.button_to')[:action]).to eq cancel_admin_order_path(order.id)
        within(find('form.button_to')) do
          expect(page).to have_button('Cancelar', disabled: true)
        end
      end
      it 'com falha na API' do
        admin = create(:admin)
        client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
        order = create(:order, client: client)
        response_cancel = Faraday::Response.new(status: 500, response_body: [])
        allow(Faraday).to receive(:patch).with("#{ApisDomains.sales}/api/v1/orders/#{order.order_code}/canceled")
                                         .and_return(response_cancel)

        login_as(admin, scope: :admin)
        visit root_path
        click_on 'Pedidos'
        within("tr##{order.id}") do
          click_on 'Detalhes'
        end
        within('form.button_to') do
          click_on 'Cancelar'
        end

        expect(page).to have_css('strong', text: 'Pendente')
      end
    end
  end
end
