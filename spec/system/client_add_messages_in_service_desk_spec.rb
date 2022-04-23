require 'rails_helper'

describe 'Cliente adiciona mensagens ao chamado' do
  it 'e visualiza formulário de envio de mensagens' do
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    category2 = create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, status: :in_progress)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end

    expect(page).to have_field('Mensagem:')
    expect(page).to have_button('Enviar')
  end

  it 'e envia mensagem com sucesso' do
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    category2 = create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, status: :in_progress)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end
    fill_in 'Mensagem:', with: 'Olá, gostaria de saber o andamento do meu chamado.'
    click_button 'Enviar'

    expect(page).to have_content('Olá, gostaria de saber o andamento do meu chamado.')
  end
end
