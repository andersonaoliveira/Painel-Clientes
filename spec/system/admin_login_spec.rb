require 'rails_helper'

describe 'Admin faz log_in' do
  it 'Com sucesso' do
    create(:admin)

    visit new_admin_session_path
    fill_in 'Email', with: 'admin@locaweb.com.br'
    fill_in 'Senha', with: '123456'
    click_on 'Log in'

    expect(current_path).to eq root_path
    expect(page).to have_content('Bem-vindo, Admin')
    within('header') do
      expect(page).to have_css('small', text: 'Administrador')
    end
  end

  it 'não acessa painel do admin caso usuário não seja administrador' do
    create(:client)

    visit new_admin_session_path
    fill_in 'Email', with: 'joao@campus.com'
    fill_in 'Senha', with: '123456'
    click_on 'Log in'

    expect(current_path).to eq new_admin_session_path
    expect(page).not_to have_content('Bem-vindo, Admin')
    within('header') do
      expect(page).not_to have_css('small', text: 'Administrador')
    end
  end
end
