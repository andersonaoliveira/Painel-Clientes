require 'rails_helper'

describe 'Administrador acessa pagina de produtos' do
  context 'Precisa ser adm para acessar' do
    it 'Cliente logado não consegue acessar' do
      cliente = create(:client)

      login_as(cliente, scope: :client)
      visit admin_products_path

      expect(current_path).to eq root_path
    end

    it 'Visitante não consegue logar' do
      visit admin_products_path

      expect(current_path).to eq root_path
    end
  end

  context 'E os produtos são atualizados' do
    it 'Com sucesso' do
      admin = create(:admin)
      client = create(:client)
      order = create(:order, order_code: '201546', client: client)
      allow(Product).to receive(:generate).with(order)
                                          .and_return(create(:product, order: order, client: client))
      allow(Order).to receive(:pull_orders).and_return(order.generate_product)

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Produtos'

      within('tr#1') do
        expect(page).to have_css('td', text: 'mail marketing')
        expect(page).to have_css('td', text: 'Aguardando pagamento')
        expect(page).to have_css('td', text: '33256256870')
      end
    end

    it 'Mas as apis estão fora do ar' do
      admin = create(:admin)

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Produtos'

      # rubocop:disable Layout/LineLength
      expect(page).to have_css('div.alert', text: 'Falha ao atualizar pedidos! Se algum pedido não aparecer, tente novamente mais tarde')
      # rubocop:enable Layout/LineLength
    end
  end

  it 'Com sucesso' do
    admin = create(:admin)
    client1 = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
    client2 = create(:client, name: 'João Silva', email: 'js@mail.com', eni: '00000000002')
    p1 = create(:product, name: 'Mail Marketing', client: client1, status: :installed,
                          server: 'QYJKQMGKR9DIQDVMO54S', code: '36ZLGR9PWB')
    p2 = create(:product, name: 'Hospedagem linux', client: client1, status: :waiting_payment)
    p3 = create(:product, name: 'Armazenamento em nuvem', client: client2, status: :waiting_payment)
    p4 = create(:product, name: 'Registro de domínio', client: client2, status: :installing)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Produtos'

    within('table') do
      within('thead') do
        expect(page).to have_css('th', text: 'Nome')
        expect(page).to have_css('th', text: 'Código')
        expect(page).to have_css('th', text: 'Status')
        expect(page).to have_css('th', text: 'Servidor')
        expect(page).to have_css('th', text: 'Documento do cliente')
      end
      within('tbody') do
        within("tr##{p1.id}") do
          expect(page).to have_css('td', text: 'Mail Marketing')
          expect(page).to have_css('td', text: p1.code)
          expect(page).to have_css('td', text: 'Instalado')
          expect(page).to have_css('td', text: p1.server)
          expect(page).to have_css('td', text: '00000000001')
        end
        within("tr##{p2.id}") do
          expect(page).to have_css('td', text: 'Hospedagem linux')
          expect(page).to have_css('td', text: '----------')
          expect(page).to have_css('td', text: 'Aguardando pagamento')
          expect(page).to have_css('td', text: '----------')
          expect(page).to have_css('td', text: '00000000001')
        end
        within("tr##{p3.id}") do
          expect(page).to have_css('td', text: 'Armazenamento em nuvem')
          expect(page).to have_css('td', text: '----------')
          expect(page).to have_css('td', text: 'Aguardando pagamento')
          expect(page).to have_css('td', text: '----------')
          expect(page).to have_css('td', text: '00000000002')
        end
        within("tr##{p4.id}") do
          expect(page).to have_css('td', text: 'Registro de domínio')
          expect(page).to have_css('td', text: p4.code)
          expect(page).to have_css('td', text: 'Instalando')
          expect(page).to have_css('td', text: '----------')
          expect(page).to have_css('td', text: '00000000002')
        end
      end
    end
  end

  it 'mas não tem nenhum produto no sistema' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Produtos'

    expect(page).to have_content('Não há produtos a serem exibidos')
  end

  context 'e acessa detalhes de um produto' do
    it 'e ve suas principais informações' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
      order = create(:order, client: client, order_code: 'aa')
      p1 = create(:product, name: 'Mail Marketing', order: order, client: client,
                            status: :installed, server: 'QYJKQMGKR9DIQDVMO54S', code: '36ZLGR9PWB')

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Produtos'
      within("tr##{p1.id}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h1', text: 'Mail Marketing')
      expect(page).to have_css('strong', text: 'Instalado')
      expect(page).to have_css('strong', text: 'MAIL')
      expect(page).to have_css('strong', text: 'aa')
      expect(page).to have_css('strong', text: 'Marketing Básico')
      expect(page).to have_css('strong', text: 'QYJKQMGKR9DIQDVMO54S')
      expect(page).to have_css('strong', text: '36ZLGR9PWB')
      expect(page).to have_css('strong', text: 'Anual')
      expect(page).to have_css('strong', text: 'R$ 250,00')
    end

    it 'e ve informações do client' do
      admin = create(:admin)
      client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
      p1 = create(:product, name: 'Mail Marketing', client: client, status: :installed,
                            server: 'QYJKQMGKR9DIQDVMO54S', code: '36ZLGR9PWB')

      login_as(admin, scope: :admin)
      visit root_path
      click_on 'Produtos'
      within("tr##{p1.id}") do
        click_on 'Detalhes'
      end

      expect(page).to have_css('h2', text: 'Pedro de Solsa')
      expect(page).to have_css('strong', text: 'ps@mail.com')
      expect(page).to have_css('strong', text: '00000000001')
      expect(page).to have_link('Detalhes', href: admin_client_path(client.id))
    end

    context 'e pode cancelar o produto' do
      it 'com sucesso' do
        admin = create(:admin)
        client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
        p1 = create(:product, name: 'Mail Marketing', client: client, status: :installed,
                              server: 'QYJKQMGKR9DIQDVMO54S', code: '36ZLGR9PWB')
        response_cancel = Faraday::Response.new(status: 201, response_body: [])
        allow(Faraday).to receive(:patch).and_return(response_cancel)

        login_as(admin, scope: :admin)
        visit root_path
        click_on 'Produtos'
        within("tr##{p1.id}") do
          click_on 'Detalhes'
        end
        within('form.button_to') do
          click_on 'Cancelar'
        end

        expect(page).to have_css('strong', text: 'Cancelado')
      end

      it 'se estiver instalado' do
        admin = create(:admin)
        client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
        p1 = create(:product, client: client)

        login_as(admin, scope: :admin)
        visit root_path
        click_on 'Produtos'
        within("tr##{p1.id}") do
          click_on 'Detalhes'
        end

        expect(find('form.button_to')[:action]).to eq cancel_admin_product_path(p1.id)
        within(find('form.button_to')) do
          expect(page).to have_button('Cancelar', disabled: true)
        end
      end
      it 'com falha na API' do
        admin = create(:admin)
        client = create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
        p1 = create(:product, name: 'Mail Marketing', client: client, status: :installed,
                              server: 'QYJKQMGKR9DIQDVMO54S', code: '36ZLGR9PWB')
        response_cancel = Faraday::Response.new(status: 500, response_body: [])
        allow(Faraday).to receive(:patch).and_return(response_cancel)

        login_as(admin, scope: :admin)
        visit root_path
        click_on 'Produtos'
        within("tr##{p1.id}") do
          click_on 'Detalhes'
        end
        within('form.button_to') do
          click_on 'Cancelar'
        end

        expect(page).to have_content('Falha ao cancelar o produto, tente novamente mais tarde!')
        expect(page).to have_css('strong', text: 'Instalado')
      end
    end
  end
end
