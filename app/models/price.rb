class Price
  attr_accessor :id, :plan, :value, :period, :period_with_price

  def initialize(id:, plan:, value:, period:)
    @id = id
    @plan = plan
    @value = value
    @period = period
    @period_with_price = "#{period} - R$ #{value}"
  end

  def self.all(plan_id)
    response = Faraday.get("#{ApisDomains.products}/api/v1/plans/#{plan_id}/prices")
    result = []

    return nil unless response.status == 200

    prices = JSON.parse(response.body)
    prices.each do |p|
      result << Price.new(id: p['id'], plan: p['plan'], value: p['value'], period: p['period'])
    end
    result
  end

  def self.find(id, plan_id)
    prices = Price.all(plan_id)
    prices.each do |p|
      return p if p.id == id
    end
  end
end
