class Admin::MessagesController < Admin::AdminController
  def create
    message_params = params.permit(:service_desk_id, :content, :admin_id, :client_id)
    message = Message.new(message_params)
    message.save
    redirect_to admin_service_desk_path(message.service_desk_id)
  end
end
