class CreateCreditCards < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_cards do |t|
      t.string :token
      t.string :nickname
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
