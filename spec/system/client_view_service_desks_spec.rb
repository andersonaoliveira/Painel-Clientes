require 'rails_helper'

describe 'Cliente visualiza seus chamados' do
  it 'mas visitante não acessa diretamente a tela de chamados' do
    visit service_desks_path

    expect(current_path).to eq new_client_session_path
  end

  it 'a partir de um link no painel de clientes' do
    client = create(:client)
    category = create(:category)
    create(:service_desk, client: client, category: category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Meus Chamados'

    expect(current_path).to eq service_desks_path
    expect(page).to have_css('h1', text: 'Chamados')
    expect(page).to have_text('Status')
    expect(page).to have_content('Aberto')
    expect(page).to have_content('Em Andamento')
    expect(page).to have_content('Aguardando Resposta do Cliente')
    expect(page).to have_content('Fechado')
    expect(page).to have_field('Busca')
    expect(page).to have_button('Filtrar')
  end

  it 'só vê seus chamados' do
    client = create(:client)
    client2 = create(:client, name: 'Anderson', email: 'anderson@teste.com', eni: 578_963_214_91)
    category = create(:category, name: 'Erro no Pedido')
    category2 = create(:category)
    order = create(:order, order_code: '5555', client: client)
    create(:product, order: order, client: client, name: 'hospedagem')
    create(:service_desk, client: client, category: category, order: order)
    create(:service_desk, client: client2, category: category2)
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Meus Chamados'

    expect(current_path).to eq service_desks_path
    expect(page).to have_content 'João'
    expect(page).to have_content 'Erro no Pedido'
    expect(page).to have_content 'Aberto'
    expect(page).not_to have_content 'Anderson'
    expect(page).not_to have_content 'Erro no Produto'
  end
end
