require 'rails_helper'

describe 'Visitante acessa a pagina inicial' do
  it 'E vê um botão para criar uma conta' do
    visit root_path

    expect(page).to have_css('h1', text: 'Bem-vindo a Central de Clientes LocaWeb')
    expect(page).to have_link('Criar conta', href: new_client_registration_path)
  end
end
