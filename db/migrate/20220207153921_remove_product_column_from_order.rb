class RemoveProductColumnFromOrder < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :product, :string
  end
end
