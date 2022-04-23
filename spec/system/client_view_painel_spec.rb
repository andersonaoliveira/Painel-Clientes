require 'rails_helper'

describe 'Usuário visualiza o painel de clientes' do
  it 'visitante não acessa diretamente a tela de pedidos' do
    visit orders_path
    expect(current_path).to eq new_client_session_path
  end

  it 'a partir da homepage' do
    client = create(:client)

    login_as(client, scope: :client)
    visit root_path

    expect(current_path).to eq root_path
    expect(page).to have_content 'Bem-vindo a Central de Clientes LocaWeb'
    expect(page).to have_link 'Perfil'
    expect(page).to have_link 'Produtos'
    expect(page).to have_link 'Pedidos'
    expect(page).to have_link 'Cartões de Crédito'
    expect(page).to have_link 'Chamados'
  end
end
