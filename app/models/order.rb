class Order < ApplicationRecord
  belongs_to :client
  has_one :product, dependent: :nullify
  has_many :service_desks, dependent: :nullify

  validates :order_code, uniqueness: true

  enum status: { pending: 0, waiting_payment_aproval: 1, paid: 2, completed: 3, canceled: 4, rejected: 5 }

  STATUS = [
    ['Pendentes', 0],
    ['Aguardando Aprovação de Pagamento', 1],
    ['Pago', 2],
    ['Finalizados', 3],
    ['Cancelados', 4],
    ['Pagamento recusado']
  ].freeze

  def self.status
    STATUS
  end

  def self.pull_orders(client_eni)
    res = Faraday.get("#{ApisDomains.sales}/api/v1/orders/clients/#{client_eni}")
    return unless res.status == 200

    orders = JSON.parse(res.body)
    orders.map do |o|
      client = Client.find_by(eni: client_eni)
      order = Order.create(order_code: o['id'], client: client, plan_id: o['plan_id'],
                           price: o['value'], frequency: o['period'])
      order.save_order
    end
  end

  def save_order
    if valid?
      generate_product
    elsif Order.find_by(order_code: order_code).product.nil?
      Order.find_by(order_code: order_code).save_order
    end
    self
  end

  def generate_product
    self.product = Product.generate(self)
  end

  def self.payment_order(params)
    request = JSON.generate(id_order: params['order_code'], credit_card_token: params['token'],
                            qty_instalments: params['installment'], cupom_code: params['cupom'],
                            client_eni: params['client_eni'], order_value: params['price'],
                            product_group_id: params['group'])
    begin
      response = Faraday.post("#{ApisDomains.payments}/api/v1/charges", request, 'Content-Type' => 'application/json')
    rescue StandardError
      return 'Falha de conexão com o sistema de pagamentos, tente novamente mais tarde!'
    end
    Order.response_payment(response, Order.find_by(order_code: params['order_code']))
  end

  def cancel
    return false unless pending?

    begin
      resp = Faraday.patch("#{ApisDomains.sales}/api/v1/orders/#{order_code}/canceled")
    rescue StandardError
      return false
    end
    return false unless resp.status == 200

    canceled!
    true
  end

  def self.response_payment(response, order)
    return nil if response.status == 500

    if response.status == 201
      order.waiting_payment_aproval!
      true
    else
      JSON.parse(response.body)
    end
  end
end
