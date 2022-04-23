require 'rails_helper'

describe 'Cliente finaliza chamado' do
  it 'a partir de um link no show do chamado' do
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

    expect(page).to have_button 'Finalizar Chamado'
  end

  it 'com sucesso' do
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    category2 = create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, status: :in_progress)
    categories = [category, category2]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end
    click_button 'Finalizar Chamado'

    expect(current_path).to eq service_desk_path(service_desk.id)
    expect(page).to have_content 'Chamado finalizado com sucesso. Não se esqueça de responder à pesquisa.'
    expect(page).to have_content('Status: Aguardando Resposta do Cliente')
  end
end
