class AddClientAndAdminToMessage < ActiveRecord::Migration[6.1]
  def change
    add_reference :messages, :client, null: true, foreign_key: true
    add_reference :messages, :admin, null: true, foreign_key: true
  end
end
