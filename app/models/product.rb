class Product < ApplicationRecord
  belongs_to :client
  belongs_to :order

  enum status: { waiting_payment: 0, paid: 1, installing: 2, installed: 3, canceled: 4 }

  def install
    return unless paid? || installing?

    resp = Faraday.post("#{ApisDomains.products}/api/v1/customer_product/installations", install_params,
                        'Content-Type' => 'application/json')
    if resp.status == 201
      self.server = JSON.parse(resp.body)['server_code']
      installed!
      order.completed!
    else
      installing!
    end
  end

  def cancel
    return unless installed?

    resp = Faraday.patch("#{ApisDomains.products}/api/v1/customer_product/installations/#{code}/inactive")
    return false unless resp.status == 201

    canceled!
    true
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(10).upcase if code.nil?
    code
  end

  def owner?(client)
    self.client == client
  end

  def self.send_order(params, value, period)
    request = JSON.generate(client_eni: params['client_eni'], plan_id: params['plan_id'],
                            period: period, value: value)

    headers = { 'Content-Type' => 'application/json' }
    response = Faraday.post("#{ApisDomains.sales}/api/v1/orders", request, headers)
    return nil if response.status == 500

    result = JSON.parse(response.body)
    return result unless response.status == 201

    Product.build_order(result)
  end

  def self.generate(order)
    resp = Faraday.get("#{ApisDomains.products}/api/v1/plans/#{order.plan_id}")
    return unless resp.status == 200

    plan_data = JSON.parse(resp.body)
    name = plan_data['product_group']['name']
    group = plan_data['product_group']['key']
    plan = plan_data['name']

    Product.create!(name: name, plan: plan, group: group, client: order.client,
                    frequency: order.frequency, price: order.price, order: order)
  end

  def self.build_order(result)
    client = Client.find_by(eni: result['client_eni'])
    order = Order.create(order_code: result['id'], client: client, frequency: result['period'],
                         price: result['value'], plan_id: result['plan_id'])
    order.save_order
  end

  def self.find_group_id(key)
    resp = Faraday.get("#{ApisDomains.products}/api/v1/product_groups")
    return unless resp.status == 200

    groups = JSON.parse(resp.body)
    groups.each do |g|
      return g['id'] if g['key'] == key
    end
  end

  private

  def install_params
    JSON.generate({ customer: client.eni, product_code: generate_code, plan_id: order.plan_id })
  end
end
