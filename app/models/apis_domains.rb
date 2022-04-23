class ApisDomains
  def self.products
    Rails.configuration.apis['products_api']
  end

  def self.sales
    Rails.configuration.apis['sales_api']
  end

  def self.payments
    Rails.configuration.apis['payment_api']
  end
end
