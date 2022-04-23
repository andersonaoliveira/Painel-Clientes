class ChangeColumnOrderIdToNullFromServiceDesk < ActiveRecord::Migration[6.1]
  def change
    change_column_null :service_desks, :order_id, true
    change_column_default :service_desks, :order_id, nil
  end
end
