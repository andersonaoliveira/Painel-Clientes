require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  context 'Cadastro de cartão' do
    it 'com sucesso' do
      client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                              address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                              birth_date: '16/03/1981', password: '123456')
      card = CreditCard.new(token: 'dgwergwe34', nickname: 'nubank', client_id: client.id)

      expect(card).to be_valid
    end

    it ' e não fornece cliente' do
      card = CreditCard.new(token: 'dgwergwe34', nickname: 'nubank', client_id: '')
      expect(card).not_to be_valid
    end

    it ' e não fornece um token' do
      client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                              address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                              birth_date: '16/03/1981', password: '123456')
      card = CreditCard.new(token: '', nickname: 'nubank', client_id: client.id)
      expect(card).not_to be_valid
    end

    it ' e não fornece um nickname' do
      client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                              address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                              birth_date: '16/03/1981', password: '123456')
      card = CreditCard.new(token: 'dgwergwe34', nickname: '', client_id: client.id)

      expect(card).not_to be_valid
    end
  end

  context 'Ativação e desativação de cartao' do
    it 'com sucesso' do
      client = create(:client)
      card = CreditCard.new(token: 'dgwergwe34', nickname: 'nubank', client_id: client.id, active: :up)
      response_cancel = Faraday::Response.new(status: 201, response_body: [])
      allow(Faraday).to receive(:post).with("#{ApisDomains.payments}/api/v1/credit_card_down", card.as_json,
                                            'Content-Type' => 'application/json').and_return(response_cancel)
      card.down
      expect(card.active).to eq 'down'
    end

    it 'e falha' do
      client = create(:client)
      card = CreditCard.new(token: 'dgwergwe34', nickname: 'nubank', client_id: client.id, active: :up)
      response_cancel = Faraday::Response.new(status: 401, response_body: [])
      allow(Faraday).to receive(:post).with("#{ApisDomains.payments}/api/v1/credit_card_down", card.as_json,
                                            'Content-Type' => 'application/json').and_return(response_cancel)
      card.down
      expect(card.active).to eq 'up'
    end
  end
end
