require 'rails_helper'

describe 'Cliente acessa página de chamados' do
  it 'visitante não vê no menu' do
    visit root_path

    expect(page).not_to have_link('Abrir Chamado')
  end

  it 'não acessa o formulário caso não esteja logado' do
    visit new_service_desk_path

    expect(current_path).to eq new_client_session_path
  end

  it 'a partir de um link na tela inicial' do
    client = create(:client)
    category = create(:category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    click_on 'Abrir Chamado'

    expect(current_path).to eq new_service_desk_path
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
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    click_on 'Abrir Chamado'
    fill_in 'Descrição', with: ''
    click_on 'Enviar'

    expect(page).to have_content('Não foi possível abrir chamado')
    expect(page).to have_content('Descrição não pode ficar em branco')
  end

  it 'com sucesso' do
    client = create(:client)
    category = create(:category)
    category2 = create(:category, name: 'Erro no Produto')
    order1 = create(:order, client: client)
    order2 = create(:order, order_code: '201444', client: client)
    create(:product, order: order1, client: client)
    create(:product, order: order2, name: 'host', client: client)
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    click_on 'Abrir Chamado'
    select 'Erro no Produto', from: 'Categoria'
    select '#201444 - host', from: 'Pedido/Produto'
    fill_in 'Descrição', with: 'Meu produto ainda não foi instalado.'
    click_on 'Enviar'

    expect(page).to have_content('Chamado aberto com sucesso!')
    expect(page).to have_css('td', text: 'Solicitante: João')
    expect(page).to have_css('td', text: 'E-mail: joao@campus.com')
    expect(page).to have_css('td', text: 'Status: Aberto')
    expect(page).to have_css('td', text: 'Categoria: Erro no Produto')
    expect(page).to have_css('td', text: 'Pedido: 201444')
    expect(page).to have_css('td', text: 'Produto: host')
    expect(page).to have_css('td', text: 'Descrição: Meu produto ainda não foi instalado.')
  end
end
