require 'rails_helper'

describe 'Administrador atribui um chamado aberto' do
  it 'com sucesso' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')
    service_desk = create(:service_desk, client: client, category: category, order: order, status: :open)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=atribuir]').click
    end

    expect(page).to have_content('Chamado atribuído com sucesso!')
    expect(page).to have_css('td', text: 'Solicitante: João')
    expect(page).to have_css('td', text: 'E-mail: joao@campus.com')
    expect(page).to have_css('td', text: 'Status: Em Andamento')
    expect(page).to have_css('td', text: 'Categoria: Erro no Pedido')
    expect(page).to have_css('td', text: 'Pedido: 201444')
    expect(page).to have_css('td', text: 'Produto: host')
    expect(page).to have_css('td', text: 'Descrição: Meu produto não está instalado')
  end

  it 'e visualiza chamado atribuído em Meus Chamados' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')
    service_desk = create(:service_desk, client: client, category: category, order: order, status: :open)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=atribuir]').click
    end
    click_on 'Meus Chamados'

    expect(page).to have_content 'João'
    expect(page).to have_content 'Erro no Pedido'
    expect(page).to have_content 'Em Andamento'
  end
end
