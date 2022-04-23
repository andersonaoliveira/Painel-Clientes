require 'rails_helper'

describe 'Através do painel cliente cadastra novo cartão' do
  it 'com sucesso' do
    client = create(:client, eni: '12345678900')
    cardbanner = File.read(Rails.root.join('spec', 'support', 'card_banner.json'))
    banner_response = Faraday::Response.new(status: 200, response_body: cardbanner)
    allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/").and_return(banner_response)
    card_data = File.read(Rails.root.join('spec', 'support', 'card.json'))
    response = Faraday::Response.new(status: 201, response_body: card_data)
    allow(Faraday).to receive(:post).and_return(response)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Cartões de Crédito'
    click_on 'Cadastrar novo cartão'
    fill_in 'Número do Cartão', with: '4004231210103535'
    fill_in 'Nome do Títular', with: 'Ruan Pourroy'
    fill_in 'Vencimento do Cartão', with: '2029-24'
    fill_in 'Código de Segurança', with: '123'
    fill_in 'CPF do Títular', with: '12345678900'
    fill_in 'Apelido para o Cartão', with: 'Nubank'
    select 'Visa', from: 'Bandeira'
    click_on 'Gravar'

    expect(current_path).to eq credit_cards_path
    expect(page).to have_content 'Nubank'
    expect(page).to have_content 'Cartão cadastrado com sucesso'
  end

  it ' e não está autenticado' do
    visit new_credit_card_path

    expect(page).not_to have_content 'Cadastrar novos Cartões'
    expect(current_path).to eq new_client_session_path
  end

  it 'e deixa os campos em branco' do
    client = create(:client)
    cardbanner = File.read(Rails.root.join('spec', 'support', 'card_banner.json'))
    banner_response = Faraday::Response.new(status: 200, response_body: cardbanner)
    allow(Faraday).to receive(:get).with("#{ApisDomains.payments}/api/v1/card_banners/").and_return(banner_response)
    card_data = File.read(Rails.root.join('spec', 'support', 'cardfails.json'))
    response = Faraday::Response.new(status: 401, response_body: card_data)
    allow(Faraday).to receive(:post).and_return(response)

    login_as(client, scope: :client)
    visit root_path
    click_on 'Cartões de Crédito'
    click_on 'Cadastrar novo cartão'
    fill_in 'Número do Cartão', with: ''
    fill_in 'Nome do Títular', with: ''
    fill_in 'Vencimento do Cartão', with: ''
    fill_in 'Código de Segurança', with: ''
    fill_in 'CPF do Títular', with: ''
    fill_in 'Apelido para o Cartão', with: ''
    select 'Visa', from: 'Bandeira'
    click_on 'Gravar'

    expect(current_path).to eq credit_cards_path
    expect(page).to have_content 'Não foi possível gravar o cartão'
    expect(response.body).to have_content 'Os campos marcados * não podem ficar em branco'
  end
end
