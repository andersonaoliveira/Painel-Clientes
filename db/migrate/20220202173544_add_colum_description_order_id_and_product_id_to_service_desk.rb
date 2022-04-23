class AddColumDescriptionOrderIdAndProductIdToServiceDesk < ActiveRecord::Migration[6.1]
  def change
    add_column :service_desks, :description, :text
    add_reference :service_desks, :order, null: false, foreign_key: true, default: 0
  end
end
