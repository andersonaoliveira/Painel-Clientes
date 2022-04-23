class CreateServiceDesks < ActiveRecord::Migration[6.1]
  def change
    create_table :service_desks do |t|
      t.references :category, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
