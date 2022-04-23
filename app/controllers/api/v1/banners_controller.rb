class Api::V1::BannersController < Api::V1::ApiController
  def show
    card = CreditCard.find_by(token: params['token'])
    response = Faraday.get("#{ApisDomains.payments}/api/v1/card_banners/#{card.card_banner_id}")
    return nil unless response.status == 200

    result = JSON.parse(response.body)
    render status: :ok, json: result.as_json
  end
end
