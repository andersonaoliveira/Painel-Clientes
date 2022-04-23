require 'rails_helper'

describe 'Administrador visualiza categorias de chamados' do
  it 'mas visitante não acessa diretamente a tela de categorias' do
    visit admin_categories_path

    expect(current_path).to eq root_path
  end

  it 'a partir de um link no painel de clientes' do
    admin = create(:admin)
    category = create(:category)
    categories = [category]
    allow(Category).to receive(:pull_categories).and_return(categories)

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'

    expect(current_path).to eq admin_categories_path
    expect(page).to have_css('h1', text: 'Categorias')
    expect(page).to have_text('Erro no Pedido')
  end

  it 'e exibe mensagem de erro caso API esteja fora do ar' do
    admin = create(:admin)
    allow(Category).to receive(:pull_categories).and_raise StandardError

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Categorias'

    # rubocop:disable Layout/LineLength
    expect(page).to have_css('div.alert', text: 'Falha ao atualizar categorias! Se alguma categoria não aparecer, tente novamente mais tarde')
    # rubocop:enable Layout/LineLength
  end
end
