class AddPlanIdFrequencyPriceToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :plan_id, :integer
    add_column :orders, :frequency, :string
    add_column :orders, :price, :string
  end
end
