require 'rails_helper'

describe 'Administrador acessa tela de categorias' do
  it 'visitante não vê no menu' do
    visit root_path

    expect(page).not_to have_link('Categorias')
  end

  it 'não acessa o formulário caso não seja administrador' do
    visit new_admin_category_path

    expect(current_path).to eq root_path
  end

  it 'a partir de um link na tela inicial' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    click_on 'Criar Nova Categoria'

    expect(current_path).to eq new_admin_category_path
    expect(page).to have_field('Nome')
  end

  it 'e alguns campos são obrigatórios' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    click_on 'Criar Nova Categoria'
    fill_in 'Nome', with: ''
    click_on 'Enviar'

    expect(page).to have_content('Não foi possível salvar categoria')
    expect(page).to have_content('Nome não pode ficar em branco')
  end

  it 'com sucesso' do
    admin = create(:admin)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    click_on 'Criar Nova Categoria'
    fill_in 'Nome', with: 'Problema de Instalação'
    click_on 'Enviar'

    expect(page).to have_content('Categoria cadastrada com sucesso!')
    expect(page).to have_content('Problema de Instalação')
  end
end
