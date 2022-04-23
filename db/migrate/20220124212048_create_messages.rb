class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.integer :author_type, default: 0
      t.string :content
      t.references :service_desk, null: false, foreign_key: true

      t.timestamps
    end
  end
end
