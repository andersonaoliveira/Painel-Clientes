require 'rails_helper'

describe 'Cliente ativo cartão' do
  it 'com sucesso' do
    client = create(:client)
    card1 = CreditCard.create!(nickname: 'nubank', client: client, token: 'f23fwef24rt', active: :down)
    response_cancel = Faraday::Response.new(status: 201, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.payments}/api/v1/credit_card_up", card1.as_json,
                                          'Content-Type' => 'application/json').and_return(response_cancel)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Cartões de Crédito'
    within('div#nubank') do
      click_on 'Ativar'
    end

    expect(page).to have_content 'Cartão ativo com sucesso'
    within('div#nubank') do
      expect(page).to have_content 'Ativo'
    end
  end
  it 'e falha' do
    client = create(:client)
    card1 = CreditCard.create!(nickname: 'nubank', client: client, token: 'f23fwef24rt', active: :down)
    response_cancel = Faraday::Response.new(status: 501, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.payments}/api/v1/credit_card_up", card1.as_json,
                                          'Content-Type' => 'application/json').and_return(response_cancel)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Cartões de Crédito'
    within('div#nubank') do
      click_on 'Ativar'
    end

    expect(page).to have_content 'Falha ao ativar o cartão, tente novamente mais tarde!'
    within('div#nubank') do
      expect(page).to have_content 'Desativado'
    end
  end
end
