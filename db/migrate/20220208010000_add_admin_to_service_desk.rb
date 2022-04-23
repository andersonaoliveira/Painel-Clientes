class AddAdminToServiceDesk < ActiveRecord::Migration[6.1]
  def change
    add_reference :service_desks, :admin, null: true, foreign_key: true
  end
end
