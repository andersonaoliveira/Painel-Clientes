class Api::V1::ApiController < ActionController::API
  protected

  def check_products_status
    Faraday.get("#{ApisDomains.products}/api/v1/periods")
    true
  rescue StandardError
    false
  end
end
