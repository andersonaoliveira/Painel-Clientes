require 'rails_helper'

describe 'Cliente deleta um chamado' do
  it 'com sucesso' do
    client = create(:client)
    category = create(:category, name: 'Erro no Pedido')
    order = create(:order, order_code: '5555', client: client)
    create(:product, order: order, client: client, name: 'hospedagem')
    service_desk = create(:service_desk, client: client, category: category, order: order)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('a#deletar').click
    end

    expect(current_path).to eq service_desks_path
    expect(page).to have_content('Chamado excluído com sucesso')
    expect(page).to have_content('Não há chamados a serem exibidos')
  end

  it 'e não consegue deletar caso status do chamado não esteja em aberto' do
    client = create(:client)
    category = create(:category, name: 'Erro no Pedido')
    order = create(:order, order_code: '5555', client: client)
    create(:product, order: order, client: client, name: 'hospedagem')
    service_desk = create(:service_desk, client: client, category: category, order: order, status: :in_progress)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Chamados'

    expect(current_path).to eq service_desks_path
    expect(page).to have_content 'João'
    expect(page).to have_content 'Erro no Pedido'
    expect(page).to have_content 'Em Andamento'
    within("tr#service-desk-#{service_desk.id}") do
      expect(page).not_to have_css('a#deletar')
    end
  end
end
