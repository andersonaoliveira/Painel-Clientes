class RemoveAuthorTypeFromMessage < ActiveRecord::Migration[6.1]
  def change
    remove_column :messages, :author_type, :integer
  end
end
