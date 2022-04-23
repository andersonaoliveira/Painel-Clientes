require 'rails_helper'

RSpec.describe Client, type: :model do
  context 'campos obrigatórios' do
    it 'email é obrigatório' do
      client = Client.new(name: 'Filipe', email: '', eni: '00000000011',
                          address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                          birth_date: '16/03/1981', password: '123456')

      expect(client).not_to be_valid
    end

    it 'senha é obrigatória' do
      client = Client.new(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                          address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                          birth_date: '16/03/1981', password: '')

      expect(client).not_to be_valid
    end

    it 'nome é obrigatório' do
      client = Client.new(name: '', email: 'teste@teste.com', eni: '00000000011',
                          address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                          birth_date: '16/03/1981', password: '123456')

      expect(client).not_to be_valid
    end

    it 'documento é obrigatório' do
      client = Client.new(name: 'Filipe', email: 'teste@teste.com', eni: '',
                          address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                          birth_date: '16/03/1981', password: '123456')

      expect(client).not_to be_valid
    end

    it 'demais campos não são obrigatórios' do
      client = Client.new(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                          address: '', city: '', state: '',
                          birth_date: '', password: '123456')

      expect(client).to be_valid
    end
  end

  context 'atributos são únicos' do
    it 'email é único' do
      Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                     address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                     birth_date: '16/03/1981', password: '123456')

      client2 = Client.new(name: 'Andrei', email: 'teste@teste.com', eni: '00000000022',
                           address: 'Rua do teste', city: 'São luís', state: 'MA',
                           birth_date: '26/07/1999', password: '654321')

      expect(client2).not_to be_valid
    end

    it 'documento é único' do
      Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                     address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                     birth_date: '16/03/1981', password: '123456')

      client2 = Client.new(name: 'Andrei', email: 'andrei@teste.com', eni: '00000000011',
                           address: 'Rua do teste', city: 'Porto Alegre', state: 'MA',
                           birth_date: '26/07/1999', password: '654321')

      expect(client2).not_to be_valid
    end
  end

  context 'formato do documento' do
    it 'cpf deve ter 11 digitos' do
      client = Client.new(name: 'Felipe', email: 'teste@teste.com', eni: '00000000011',
                          address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                          birth_date: '16/03/1981', password: '123456')

      expect(client).to be_valid
    end

    it 'cnpj deve ter 14 digitos' do
      client = Client.new(name: 'Felipe', email: 'teste@teste.com', eni: '00000000000001',
                          address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                          birth_date: '16/03/1981', password: '123456')

      expect(client).to be_valid
    end

    it 'qualquer outro tamanho é inválido' do
      c1 = Client.new(name: 'Filipe', email: 'teste@teste.com', eni: '000000000', password: '123456')
      c2 = Client.new(name: 'Andrei', email: 'andrei@teste.com', eni: '0000000000000', password: '123456')
      c3 = Client.new(name: 'Ruan', email: 'ruan@teste.com', eni: '0000000', password: '123456')

      expect(c1).not_to be_valid
      expect(c2).not_to be_valid
      expect(c3).not_to be_valid
    end
  end
end
