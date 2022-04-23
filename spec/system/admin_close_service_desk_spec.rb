require 'rails_helper'

describe 'Administrador encerra chamado' do
  it 'a partir de um botão no show do chamado' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, admin: admin, status: :in_progress)
    order = create(:order, order_code: '201444', client: client)
    create(:product, order: order, client: client, name: 'host')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end

    expect(page).to have_button 'Finalizar Chamado'
  end

  it 'com sucesso' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category, name: 'Dúvida')
    create(:category, name: 'Erro no Produto')
    service_desk = create(:service_desk, client: client, category: category, admin: admin, status: :in_progress)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'
    within("tr#service-desk-#{service_desk.id}") do
      find('[name=detalhes]').click
    end
    click_button 'Finalizar Chamado'

    expect(current_path).to eq admin_service_desk_path(service_desk.id)
    expect(page).to have_content 'Chamado finalizado com sucesso.'
    expect(page).to have_content('Status: Aguardando Resposta do Cliente')
  end
end
