require 'rails_helper'

describe 'Cliente desativa cartão' do
  it 'com sucesso' do
    client = create(:client)
    card1 = CreditCard.create!(nickname: 'nubank', client: client, token: 'f23fwef24rt')
    response_cancel = Faraday::Response.new(status: 201, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.payments}/api/v1/credit_card_down", card1.as_json,
                                          'Content-Type' => 'application/json').and_return(response_cancel)
    allow_any_instance_of(CreditCardsController).to receive(:check_payment_status).and_return(true)

    login_as(client, scope: :client)
    visit credit_cards_path
    within('div#nubank') do
      click_on 'Desativar'
    end

    expect(page).to have_content 'Cartão desativado com sucesso'
    within('div#nubank') do
      expect(page).to have_content 'Desativado'
    end
  end
  it 'e falha' do
    client = create(:client)
    card1 = CreditCard.create!(nickname: 'nubank', client: client, token: 'f23fwef24rt')
    response_cancel = Faraday::Response.new(status: 501, response_body: [])
    allow(Faraday).to receive(:post).with("#{ApisDomains.payments}/api/v1/credit_card_down", card1.as_json,
                                          'Content-Type' => 'application/json').and_return(response_cancel)
    allow_any_instance_of(CreditCardsController).to receive(:check_payment_status).and_return(true)

    login_as(client, scope: :client)
    visit credit_cards_path
    within('div#nubank') do
      click_on 'Desativar'
    end

    expect(page).to have_content 'Falha ao desativar o cartão, tente novamente mais tarde!'
    within('div#nubank') do
      expect(page).to have_content 'Ativo'
    end
  end

  it 'e pagamentos esta fora do ar' do
    client = create(:client)
    CreditCard.create!(nickname: 'nubank', client: client, token: 'f23fwef24rt')
    allow_any_instance_of(CreditCardsController).to receive(:check_payment_status).and_return(false)

    login_as(client, scope: :client)
    visit credit_cards_path
    within('div#nubank') do
      click_on 'Desativar'
    end

    expect(page).to have_content 'Indisponível no momento, tente novamente mais tarde'
    within('div#nubank') do
      expect(page).to have_content 'Ativo'
    end
  end
end
