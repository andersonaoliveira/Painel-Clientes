require 'rails_helper'

describe 'order API' do
  context 'PATCH /api/v1/orders/payment' do
    it 'succesfully' do
      client = create(:client)
      order = create(:order, order_code: '201546', client: client, status: :waiting_payment_aproval)
      product = create(:product, client: client, status: :waiting_payment, order: order, code: 'XPT25WTHRW')
      params = JSON.generate({ customer: client.eni, product_code: 'XPT25WTHRW', plan_id: product.order.plan_id })
      resp = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
      allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                            'Content-Type' => 'application/json')
                                      .and_return(resp)
      allow_any_instance_of(Api::V1::ApiController).to receive(:check_products_status).and_return(true)
      params = '{"order_code": "201546", "status": "paid", "total_charge": "200"}'
      headers = { 'CONTENT_TYPE' => 'application/json' }
      patch '/api/v1/orders/payment', params: params, headers: headers

      r1 = Order.find(order.id)
      r2 = Product.find(product.id)

      expect(response.status).to eq 200
      expect(r1.status).to eq 'completed'
      expect(r2.price).to eq '200'
      expect(r2.status).to eq 'installed'
    end

    it 'pedido não existe' do
      params = '{"order_code": "201546", "status": "paid"}'
      headers = { 'CONTENT_TYPE' => 'application/json' }
      patch '/api/v1/orders/payment', params: params, headers: headers

      expect(response.status).to eq 404
      expect(response.body).to include 'Pedido não encontrado'
    end

    it 'pedido com status pendente' do
      client = create(:client)
      order = create(:order, order_code: '201546', client: client, status: :pending)
      product = create(:product, client: client, status: :waiting_payment, order: order)
      params = '{"order_code": "201546", "status": "paid"}'
      headers = { 'CONTENT_TYPE' => 'application/json' }
      patch '/api/v1/orders/payment', params: params, headers: headers

      r1 = Order.find(order.id)
      r2 = Product.find(product.id)

      expect(response.status).to eq 406
      expect(response.body).to include 'Pedido não liberado para pagamento'
      expect(r1.status).not_to eq 'paid'
      expect(r2.status).not_to eq 'paid'
    end

    context 'checka se a api de pagamento esta disponivel' do
      it 'com sucesso' do
        client = create(:client)
        order = create(:order, order_code: '201546', client: client, status: :waiting_payment_aproval)
        product = create(:product, client: client, status: :waiting_payment, order: order, code: 'XPT25WTHRW')
        params = JSON.generate({ customer: client.eni, product_code: 'XPT25WTHRW', plan_id: product.order.plan_id })
        resp = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
        allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                              'Content-Type' => 'application/json')
                                        .and_return(resp)
        allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/periods").and_return(resp)
        params = '{"order_code": "201546", "status": "paid"}'
        headers = { 'CONTENT_TYPE' => 'application/json' }
        patch '/api/v1/orders/payment', params: params, headers: headers
        prod = Product.find(product.id)

        expect(prod.status).to eq 'installed'
      end

      it 'e não está' do
        client = create(:client)
        order = create(:order, order_code: '201546', client: client, status: :waiting_payment_aproval)
        product = create(:product, client: client, status: :waiting_payment, order: order, code: 'XPT25WTHRW')
        params = JSON.generate({ customer: client.eni, product_code: 'XPT25WTHRW', plan_id: product.order.plan_id })
        resp = Faraday::Response.new(status: 201, response_body: '{"server_code": "SRAP"}')
        allow(Faraday).to receive(:post).with("#{ApisDomains.products}/api/v1/customer_product/installations", params,
                                              'Content-Type' => 'application/json')
                                        .and_return(resp)
        allow(Faraday).to receive(:get).with("#{ApisDomains.products}/api/v1/periods").and_raise('ERROR')
        params = '{"order_code": "201546", "status": "paid"}'
        headers = { 'CONTENT_TYPE' => 'application/json' }
        patch '/api/v1/orders/payment', params: params, headers: headers
        prod = Product.find(product.id)

        expect(prod.status).to eq 'paid'
      end
    end
    context 'patch /api/v1/cancelation/:id' do
      it 'succesfully' do
        client = create(:client)
        order = create(:order, order_code: '201546', client: client, status: :waiting_payment_aproval)
        params = JSON.generate({ id: order.order_code })
        headers = { 'CONTENT_TYPE' => 'application/json' }
        patch "/api/v1/cancelation/#{order.order_code}", params: params, headers: headers

        result = Order.find(order.id)

        expect(response.status).to eq 200
        expect(result.status).to eq 'canceled'
      end
      it 'pedido já concluído' do
        client = create(:client)
        order = create(:order, order_code: '201546', client: client, status: :completed)
        params = JSON.generate({ id: order.order_code })
        headers = { 'CONTENT_TYPE' => 'application/json' }
        patch "/api/v1/cancelation/#{order.order_code}", params: params, headers: headers

        result = Order.find(order.id)

        expect(response.status).to eq 406
        expect(response.body).to eq '{"alert": "Pedido já foi concluído ou cancelado"}'
        expect(result.status).to eq 'completed'
      end
      it 'pedido já cancelado' do
        client = create(:client)
        order = create(:order, order_code: '201546', client: client, status: :canceled)
        params = JSON.generate({ id: order.order_code })
        headers = { 'CONTENT_TYPE' => 'application/json' }
        patch "/api/v1/cancelation/#{order.order_code}", params: params, headers: headers

        result = Order.find(order.id)

        expect(response.status).to eq 406
        expect(response.body).to eq '{"alert": "Pedido já foi concluído ou cancelado"}'
        expect(result.status).to eq 'canceled'
      end
    end
  end
end
