require 'rails_helper'

RSpec.describe Price, type: :model do
  context '.self.all' do
    it 'com sucesso' do
      price_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'price.json'))
      response = Faraday::Response.new(status: 200, response_body: price_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1/prices")
                                     .and_return(response)
      result = Price.all(1)

      expect(result.length).to eq 1
      expect(result[0].value).to eq '30.0'
    end

    it 'sem resposa' do
      response = Faraday::Response.new(status: 500, response_body: {})
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/plans/1/prices")
                                     .and_return(response)
      result = Price.all(1)

      expect(result).to be_nil
    end
  end
end
