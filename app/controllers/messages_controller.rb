class MessagesController < ApplicationController
  before_action :authenticate_client!

  def create
    message_params = params.require(:message).permit(:service_desk_id, :content, :admin_id, :client_id)
    message = Message.new(message_params)
    message.save
    redirect_to service_desk_path(message.service_desk_id)
  end
end
