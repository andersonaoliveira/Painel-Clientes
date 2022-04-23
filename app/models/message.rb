class Message < ApplicationRecord
  belongs_to :service_desk
  belongs_to :admin, optional: true
  belongs_to :client, optional: true

  def created
    created_at.strftime('%d/%m/%Y - %H:%M')
  end
end
