require 'rails_helper'

describe 'Cliente responde pesquisa após encerramento do chamado' do
  it 'com sucesso' do
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    category2 = create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, status: :wait_approval_client)
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

    expect(page).to have_content('Seu problema foi resolvido?')
    expect(page).to have_content('Sim')
    expect(page).to have_content('Não')
  end

  it 'não visualiza caso chamado não esteja aguardando resposta' do
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    category2 = create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, status: :wait_approval_client)
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
    choose(option: 1)
    click_button 'Enviar'

    expect(page).to have_content('Obrigado pela resposta. Qualquer dúvida entre em contato conosco.')
    expect(page).not_to have_content('Seu problema foi resolvido?')
    expect(page).not_to have_content('Sim')
    expect(page).not_to have_content('Não')
  end
end
