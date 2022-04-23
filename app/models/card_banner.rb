class CardBanner
  attr_accessor :id, :name, :max_instalments

  def initialize(id:, name:, max_instalments:)
    @id = id
    @name = name
    @max_instalments = max_instalments
  end

  def self.all
    response = Faraday.get("#{ApisDomains.payments}/api/v1/card_banners/")
    result = []
    return nil unless response.status == 200

    card_banners = JSON.parse(response.body)
    card_banners.each do |card|
      result << CardBanner.new(id: card['id'], name: card['name'], max_instalments: card['max_instalments'])
    end
    result
  end
end
