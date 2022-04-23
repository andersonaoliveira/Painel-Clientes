class HomeController < ApplicationController
  def index
    if client_signed_in?
      @client = current_client
    elsif admin_signed_in?
      @admin = current_admin
    end
  end

  def profile
    @client = current_client
  end
end
