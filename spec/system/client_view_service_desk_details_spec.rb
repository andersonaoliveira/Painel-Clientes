require 'rails_helper'

describe 'Cliente visualiza detalhes do chamado' do
  it 'e não acessa tela diretamente quando não logado' do
    visit service_desk_path(1)

    expect(current_path).to eq new_client_session_path
  end

  it 'e vê dados do chamado' do
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end

    expect(current_path).to eq service_desk_path(service_desk.id)
    expect(page).to have_css('td', text: 'Solicitante: João')
    expect(page).to have_css('td', text: 'E-mail: joao@campus.com')
    expect(page).to have_css('td', text: 'Status: Aberto')
    expect(page).to have_css('td', text: 'Categoria: Dúvida')
    expect(page).not_to have_css('td', text: 'Pedido:')
    expect(page).not_to have_css('td', text: 'Produto:')
    expect(page).to have_css('td', text: 'Descrição: Meu produto não está instalado')
  end

  it 'e não vê dados de chamados que não seja os próprios' do
    client = create(:client)
    client2 = create(:client, email: 'anderson@campus.com.br', eni: '57896321419')
    category = create(:category, name: 'Dúvida')
    category2 = create(:category, name: 'Erro no Produto')
    create(:service_desk, client: client, category: category)
    create(:service_desk, client: client2, category: category2)
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit service_desk_path(2)

    expect(current_path).to eq service_desks_path
    expect(page).to have_content('Chamado não encontrado!')
  end
end
