class ChangeColumnActiveToInteger < ActiveRecord::Migration[6.1]
  def change
    change_column :credit_cards, :active, :integer, default: 0
  end
end
