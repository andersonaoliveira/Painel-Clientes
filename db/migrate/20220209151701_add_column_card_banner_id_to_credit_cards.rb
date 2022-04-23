class AddColumnCardBannerIdToCreditCards < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_cards, :card_banner_id, :integer
  end
end
