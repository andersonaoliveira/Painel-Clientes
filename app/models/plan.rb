class Plan
  attr_accessor :id, :name, :group

  def initialize(id:, name:, group:)
    @id = id
    @name = name
    @group = group
  end

  def self.all
    response = Faraday.get("#{ApisDomains.products}/api/v1/plans")
    result = []

    return nil unless response.status == 200

    plans = JSON.parse(response.body)
    plans.each do |p|
      result << Plan.new(id: p['id'], name: p['name'], group: p['product_group']['key'])
    end
    result
  end

  def self.group_search(group)
    plans = Plan.all
    results = []
    plans.each do |p|
      results << p if p.group == group
    end
    results
  end

  def self.find(id)
    plans = Plan.all
    plans.each do |p|
      return p if p.id == id
    end
  end
end
