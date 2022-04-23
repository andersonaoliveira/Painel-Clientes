class Category < ApplicationRecord
  has_many :service_desks, dependent: :nullify
  validates :name, presence: true

  enum status: { active: 0, inactive: 1 }

  def self.pull_categories
    response = Faraday.get("#{ApisDomains.products}/api/v1/product_groups")
    return unless response.status == 200

    categories = JSON.parse(response.body)
    categories.map do |category|
      cat = Category.where(name: category['name'])
      Category.create(name: category['name']) if cat.empty?
    end
  end

  def self.all_categories
    begin
      pull_categories
    rescue StandardError
      return Category.all.active
    end

    Category.all.active
  end
end
