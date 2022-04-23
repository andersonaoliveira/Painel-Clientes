class AddStatusToCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :status, :integer, default: 0
  end
end
