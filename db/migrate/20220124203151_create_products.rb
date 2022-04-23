class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :group
      t.string :plan
      t.string :frequency
      t.string :price
      t.string :server
      t.string :code
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
