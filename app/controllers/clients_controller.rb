class ClientsController < ApplicationController
  def changeaccount
    @client = current_client
  end

  def account_update
    @client = current_client
  end
end
