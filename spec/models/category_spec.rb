require 'rails_helper'

RSpec.describe Category, type: :model do
  context 'pull_categories' do
    it 'salva categorias com sucesso' do
      categories_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'categories.json'))
      response_categories = Faraday::Response.new(status: 200, response_body: categories_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/product_groups")
                                     .and_return(response_categories)
      Category.pull_categories

      result = Category.all

      expect(result.length).to eq 2
      expect(result[0].name).to eq 'Email'
      expect(result[1].name).to eq 'Cloud'
    end

    it 'não salva categorias repetidas' do
      categories_data = File.read(Rails.root.join('spec', 'support', 'api_resources', 'repeted_categories.json'))
      response_categories = Faraday::Response.new(status: 200, response_body: categories_data)
      allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/product_groups")
                                     .and_return(response_categories)
      Category.pull_categories

      result = Category.all

      expect(result.length).to eq 1
      expect(result[0].name).to eq 'Cloud'
    end
  end
  context '.all_categories' do
    it 'retorna categorias ativas com API fora do ar' do
      create(:category)
      allow(Category).to receive(:pull_categories).and_return(StandardError)

      result = Category.all_categories

      expect(result.length).to eq 1
      expect(result[0].name).to eq 'Erro no Pedido'
    end
  end
end
