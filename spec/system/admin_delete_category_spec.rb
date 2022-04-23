require 'rails_helper'

describe 'Administrador deleta uma categoria' do
  it 'com sucesso' do
    admin = create(:admin)
    category = create(:category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'
    within("tr#category-#{category.id}") do
      find('[name=deletar]').click
    end

    expect(current_path).to eq admin_categories_path
    expect(page).to have_content('Categoria excluída com sucesso')
    expect(page).not_to have_content('Erro no Pedido')
  end
end
