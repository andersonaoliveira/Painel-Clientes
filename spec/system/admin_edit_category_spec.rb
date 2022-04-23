require 'rails_helper'

describe 'Administrador acessa tela de categorias' do
  it 'não acessa o formulário caso não seja administrador' do
    visit edit_admin_category_path(1)

    expect(current_path).to eq root_path
  end

  it 'a partir de um link na tela inicial' do
    admin = create(:admin)
    category = create(:category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    within("tr#category-#{category.id}") do
      find('[name=editar]').click
    end

    expect(current_path).to eq edit_admin_category_path(1)
    expect(page).to have_field('Nome')
  end

  it 'e alguns campos são obrigatórios' do
    admin = create(:admin)
    category = create(:category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    within("tr#category-#{category.id}") do
      find('[name=editar]').click
    end
    fill_in 'Nome', with: ''
    click_on 'Enviar'

    expect(page).to have_content('Não foi possível editar categoria')
    expect(page).to have_content('Nome não pode ficar em branco')
  end

  it 'com sucesso' do
    admin = create(:admin)
    category = create(:category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    within("tr#category-#{category.id}") do
      find('[name=editar]').click
    end
    fill_in 'Nome', with: 'Problema de Instalação'
    click_on 'Enviar'

    expect(page).to have_content('Categoria alterada com sucesso!')
    expect(page).to have_content('Problema de Instalação')
  end
end
