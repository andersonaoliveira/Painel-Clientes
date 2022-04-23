class CreditCard < ApplicationRecord
  belongs_to :client
  validates :token, :nickname, presence: true
  enum active: { up: 0, down: 1 }

  def self.save(card, client_eni)
    response = Faraday.post("#{ApisDomains.payments}/api/v1/credit_cards/",
                            { number: card['number'], holder_name: card['holder_name'],
                              valid_date: card['valid_date'], security_code: card['security_code'],
                              cpf: client_eni, card_banner_id: card['card_banner_id'] },
                            'Content_Type' => 'application/json')
    return nil unless response.status == 201

    CreditCard.create!(token: JSON.parse(response.body)['token'], nickname: card['nickname'],
                       client_id: card['client_id'], card_banner_id: card['card_banner_id'])
  end

  def down
    resp = Faraday.post("#{ApisDomains.payments}/api/v1/credit_card_down", as_json,
                        'Content-Type' => 'application/json')
    return false unless resp.status == 201

    down!
    true
  end

  def up
    resp = Faraday.post("#{ApisDomains.payments}/api/v1/credit_card_up", as_json, 'Content-Type' => 'application/json')
    return false unless resp.status == 201

    up!
    true
  end
end
