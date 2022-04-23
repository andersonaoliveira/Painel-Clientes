admin = Admin.create!(name: 'João', email: 'joao@locaweb.com.br', password: '123456')

client = Client.create!(name: 'Filipe', email: 'filipe@campus.com', eni: '11111111111',
                        address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                        birth_date: '16/03/1981', password: '123456', phone: '5191002819')

category = Category.create!(name: 'Dúvida')

ServiceDesk.create!(client: client, admin: admin, category: category, description: 'Não sei localizar meus produtos.')
