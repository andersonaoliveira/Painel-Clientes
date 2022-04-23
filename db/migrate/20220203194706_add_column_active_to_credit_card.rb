class AddColumnActiveToCreditCard < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_cards, :active, :boolean, default: true
  end
end
