require 'rails_helper'

describe 'Admin pesquisa por clientes' do
  it 'Com sucesso' do
    admin = create(:admin)
    create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
    create(:client, name: 'João Silva', email: 'js@mail.com', eni: '00000000002')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Clientes'
    fill_in 'busca', with: '00000000001'
    click_on 'Pesquisar'

    within('table') do
      within('thead') do
        expect(page).to have_css('th', text: 'Nome')
        expect(page).to have_css('th', text: 'Email')
        expect(page).to have_css('th', text: 'Documento')
      end
      within('tbody') do
        expect(page).to have_css('td', text: 'Pedro de Solsa')
        expect(page).to have_css('td', text: 'ps@mail.com')
        expect(page).to have_css('td', text: '00000000001')
        expect(page).not_to have_css('td', text: 'João Silva')
        expect(page).not_to have_css('td', text: 'js@mail.com')
        expect(page).not_to have_css('td', text: '00000000002')
      end
    end
  end
  it 'e não localiza nada' do
    admin = create(:admin)
    create(:client, name: 'Pedro de Solsa', email: 'ps@mail.com', eni: '00000000001')
    create(:client, name: 'João Silva', email: 'js@mail.com', eni: '00000000002')

    login_as(admin, scope: :admin)
    visit root_path
    click_on 'Clientes'
    fill_in 'busca', with: '99999999999'
    click_on 'Pesquisar'

    expect(page).to have_content 'Não há clientes a serem exibidos'
    expect(page).not_to have_css('table')
  end
end
