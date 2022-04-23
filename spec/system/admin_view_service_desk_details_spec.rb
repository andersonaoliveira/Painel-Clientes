require 'rails_helper'

describe 'Administrador visualiza um chamado' do
  it 'e não acessa tela diretamente quando não logado' do
    visit admin_service_desk_path(1)

    expect(current_path).to eq root_path
  end

  it 'e vê dados do chamado' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end

    expect(current_path).to eq admin_service_desk_path(service_desk.id)
    expect(page).to have_css('td', text: 'Solicitante: João')
    expect(page).to have_css('td', text: 'E-mail: joao@campus.com')
    expect(page).to have_css('td', text: 'Status: Aberto')
    expect(page).to have_css('td', text: 'Categoria: Dúvida')
    expect(page).not_to have_css('td', text: 'Pedido:')
    expect(page).not_to have_css('td', text: 'Produto:')
    expect(page).to have_css('td', text: 'Descrição: Meu produto não está instalado')
  end
end
