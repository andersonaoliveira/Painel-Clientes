class RemovePlanFromOrder < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :plan, :string
  end
end
