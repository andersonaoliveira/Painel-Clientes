require 'rails_helper'

describe 'Administrador adiciona mensagens ao chamado' do
  it 'e visualiza formulário de envio de mensagens' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, admin: admin, status: :in_progress)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Meus Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end

    expect(page).to have_field('Mensagem:')
    expect(page).to have_button('Enviar')
  end

  it 'e envia mensagem com sucesso' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, admin: admin, status: :in_progress)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Meus Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end
    fill_in 'Mensagem:', with: 'Olá, seu chamado já está sendo processado.'
    click_button 'Enviar'

    expect(page).to have_content('Olá, seu chamado já está sendo processado.')
  end

  it 'e só consegue enviar mensagem para seus chamados atribuídos' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, status: :in_progress)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end

    expect(page).not_to have_field('Mensagem:')
    expect(page).not_to have_button('Enviar')
  end
end
