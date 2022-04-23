require 'rails_helper'

describe 'Cliente edita um chamado em aberto' do
  it 'visitante não vê no menu' do
    visit root_path

    expect(page).not_to have_link('Chamados')
  end

  it 'não acessa o formulário caso não esteja logado' do
    visit edit_service_desk_path(1)

    expect(current_path).to eq new_client_session_path
  end

  it 'a partir de um link na tela inicial' do
    client = create(:client)
    category = create(:category)
    service_desk = create(:service_desk, client: client, category: category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=editar]').click
    end

    expect(current_path).to eq edit_service_desk_path(1)
    expect(page).to have_css('label', text: 'João')
    expect(page).to have_css('label', text: 'joao@campus.com')
    expect(page).to have_field('Categoria')
    expect(page).to have_field('Pedido')
    expect(page).to have_field('Produto')
    expect(page).to have_field('Descrição')
    expect(page).to have_button('Enviar')
  end

  it 'e alguns campos são obrigatórios' do
    client = create(:client)
    category = create(:category)
    service_desk = create(:service_desk, client: client, category: category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=editar]').click
    end
    fill_in 'Descrição', with: ''
    click_on 'Enviar'

    expect(page).to have_content('Não foi possível editar chamado')
    expect(page).to have_content('Descrição não pode ficar em branco')
  end

  it 'com sucesso' do
    client = create(:client)
    category = create(:category)
    category2 = create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=editar]').click
    end
    select 'Erro no Produto', from: 'Categoria'
    select '#201444 - host', from: 'Pedido/Produto'
    fill_in 'Descrição', with: 'Meu produto ainda não foi instalado.'
    click_on 'Enviar'

    expect(page).to have_content('Chamado alterado com sucesso!')
    expect(page).to have_css('td', text: 'Solicitante: João')
    expect(page).to have_css('td', text: 'E-mail: joao@campus.com')
    expect(page).to have_css('td', text: 'Status: Aberto')
    expect(page).to have_css('td', text: 'Categoria: Erro no Produto')
    expect(page).to have_css('td', text: 'Pedido: 201444')
    expect(page).to have_css('td', text: 'Produto: host')
    expect(page).to have_css('td', text: 'Descrição: Meu produto ainda não foi instalado.')
  end
end
