require 'rails_helper'

describe 'Administrador navega pelo menu do painel' do
  it 'com sucesso' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path

    within('div.ls-sidebar-inner') do
      expect(page).to have_link('Clientes')
      expect(page).to have_link('Produtos')
      expect(page).to have_link('Pedidos')
      expect(page).to have_link('Chamados')
      expect(page).not_to have_link('Cartões de Crédito')
      expect(page).not_to have_link('Abrir Chamado')
    end
  end

  it 'E acessa a pagina de clientes' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path

    click_on 'Clientes'

    expect(current_path).to eq admin_clients_path
  end
end
