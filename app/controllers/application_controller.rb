class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :not_simultaneous_users

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name eni phone address city state legal_name birth_date])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email password password_confirmation
                                                                current_password name phone address city state
                                                                legal_name birth_date])
  end

  def not_simultaneous_users
    sign_out(current_client) if current_admin && current_client
  end

  def check_payment_status
    Faraday.get("#{ApisDomains.payments}/api/v1/card_banners/")
    true
  rescue StandardError
    false
  end

  def check_products_status
    Faraday.get("#{ApisDomains.products}/api/v1/periods")
    true
  rescue StandardError
    false
  end
end
