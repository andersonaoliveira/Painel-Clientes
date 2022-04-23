class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :order_code
      t.string :plan
      t.references :client, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
