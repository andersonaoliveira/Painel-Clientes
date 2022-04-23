require 'rails_helper'

describe 'Admin visualiza chamados abertos' do
  it 'mas visitante não acessa diretamente a tela de chamados do admin' do
    visit admin_service_desks_path

    expect(current_path).to eq root_path
  end

  it 'a partir de um link no painel de administrador' do
    admin = create(:admin)
    client = create(:client)
    category = create(:category)
    create(:service_desk, client: client, category: category)

    login_as(admin, scope: :admin)
    visit root_path

    expect(page).to have_link 'Todos os Chamados'
    expect(page).to have_link 'Meus Chamados'
  end

  it 'e visualiza todos os chamados' do
    admin = create(:admin)
    client = create(:client)
    client2 = create(:client, name: 'Anderson', email: 'anderson@teste.com', eni: 578_963_214_91)
    category = create(:category, name: 'Erro no Produto')
    category2 = create(:category)
    order = create(:order, order_code: '5555', client: client)
    create(:product, order: order, client: client, name: 'hospedagem')
    create(:service_desk, client: client, category: category, order: order, status: :in_progress, admin: admin)
    create(:service_desk, client: client2, category: category2)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Todos os Chamados'

    expect(current_path).to eq admin_service_desks_path
    expect(page).to have_content 'João'
    expect(page).to have_content 'Erro no Pedido'
    expect(page).to have_content 'Aberto'
    expect(page).to have_content 'Anderson'
    expect(page).to have_content 'Erro no Produto'
  end

  it 'e visualiza apenas os chamados atribuídos a ele' do
    admin = create(:admin)
    client = create(:client)
    client2 = create(:client, name: 'Anderson', email: 'anderson@teste.com', eni: 578_963_214_91)
    category = create(:category, name: 'Erro no Pedido')
    category2 = create(:category)
    order = create(:order, order_code: '5555', client: client)
    create(:product, order: order, client: client, name: 'hospedagem')
    create(:service_desk, client: client, category: category, order: order, status: :in_progress, admin: admin)
    create(:service_desk, client: client2, category: category2)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Meus Chamados'

    expect(current_path).to eq admin_my_service_desks_path
    expect(page).to have_content 'João'
    expect(page).to have_content 'Erro no Pedido'
    expect(page).to have_content 'Aberto'
    expect(page).not_to have_content 'Anderson'
    expect(page).not_to have_content 'Erro no Produto'
  end
end
