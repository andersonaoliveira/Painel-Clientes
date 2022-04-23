require 'rails_helper'

describe 'Cliente acessa o painel de Cartões de Crédito vê ' do
  it 'seus cartões cadastrados' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456')

    CreditCard.create!(nickname: 'Itau', client: client, token: 'fas3twregrhg')
    CreditCard.create!(nickname: 'nubank', client: client, token: 'f23fwef24rt')

    login_as(client, scope: :client)
    visit credit_cards_path
    expect(page).to have_content 'Cartões de Crédito'
    expect(page).to have_content 'Itau'
    expect(page).to have_content 'nubank'
  end
  it 'nenhum cartão' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456')
    login_as(client, scope: :client)
    visit credit_cards_path

    expect(page).to have_content 'Não há cartões de créditos a serem exibidos'
    expect(page).to have_content 'Cartões de Crédito'
  end
end
