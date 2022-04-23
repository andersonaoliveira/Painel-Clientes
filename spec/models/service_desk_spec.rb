require 'rails_helper'

RSpec.describe ServiceDesk, type: :model do
  it 'description é obrigatório' do
    client = create(:client)
    category = create(:category)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    service_desk = ServiceDesk.new(client: client, category: category, order: order, description: '')
    result = service_desk.valid?

    expect(result).to eq false
  end

  it 'category_id é obrigatório' do
    client = create(:client)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    service_desk = ServiceDesk.new(client: client, category: nil, order: order, description: 'Teste de model')
    result = service_desk.valid?

    expect(result).to eq false
  end

  it 'client_id é obrigatório' do
    client = create(:client)
    category = create(:category)
    order = create(:order, client: client)
    create(:product, order: order, client: client)
    service_desk = ServiceDesk.new(client: nil, category: category, order: order, description: 'Teste de model')
    result = service_desk.valid?

    expect(result).to eq false
  end
end
