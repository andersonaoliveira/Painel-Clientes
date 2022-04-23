require 'rails_helper'

describe 'Cliente tenta editar seus próprios dados' do
  it 'e acessa menu de edição' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456', phone: '5191002819')

    login_as(client, scope: :client)
    visit root_path
    click_link 'Perfil'
    click_link 'Editar conta'

    expect(page).to have_css('h2', text: 'Editar Dados da Conta')
  end

  it 'e recebe mensagem de alterado com sucesso' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456', phone: '5191002819')

    login_as(client, scope: :client)
    visit root_path
    click_link 'Perfil'
    click_on('Editar conta')
    fill_in 'Nome', with: 'Testador da hora'
    fill_in 'Senha Atual', with: '123456'
    click_on 'Atualizar'

    expect(page).to have_content('A sua conta foi atualizada com sucesso.')
  end

  it 'e consegue alterar seu telefone' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456', phone: '5191002819')

    login_as(client, scope: :client)
    visit root_path
    click_link 'Perfil'
    click_on('Editar conta')
    fill_in 'Telefone', with: '90909090'
    fill_in 'Senha Atual', with: '123456'
    click_on 'Atualizar'
    click_link 'Perfil'

    expect(page).to have_field('Telefone', with: '90909090')
    expect(page).not_to have_field('Telefone', with: '5191002819')
  end

  it 'e consegue alterar todos dados pessoais' do
    client = Client.create!(name: 'Filipe', email: 'teste@teste.com', eni: '00000000011',
                            address: 'Rua do teste', city: 'Porto Alegre', state: 'RS',
                            birth_date: '16/03/1981', password: '123456', phone: '5191002819')

    login_as(client, scope: :client)
    visit '/clients/edit'
    fill_in 'Nome', with: 'Testador da hora'
    fill_in 'Email', with: 'emaildotestador@teste.com.br'
    fill_in 'Endereço', with: 'Rua da testada, 25'
    fill_in 'Cidade', with: 'Testamento'
    fill_in 'Estado', with: 'TS'
    fill_in 'Telefone', with: '90909090'
    fill_in 'Data de Nascimento', with: '23/01/1900'
    fill_in 'Senha Atual', with: '123456'
    click_on 'Atualizar'
    click_link 'Perfil'

    expect(page).to have_field('Nome', with: 'Testador da hora')
    expect(page).to have_field('Email', with: 'emaildotestador@teste.com.br')
    expect(page).to have_field('Endereço', with: 'Rua da testada, 25')
    expect(page).to have_field('Cidade/Estado', with: 'Testamento / TS')
    expect(page).to have_field('Telefone', with: '90909090')
    expect(page).to have_field('Data de Nascimento', with: '23/01/1900')
    expect(page).not_to have_field('Nome', with: 'Filipe')
    expect(page).not_to have_field('Email', with: 'teste@teste.com')
    expect(page).not_to have_field('Endereço', with: 'Rua do teste')
    expect(page).not_to have_field('Cidade/Estado', with: 'Porto Alegre / RS')
    expect(page).not_to have_field('Telefone', with: '5191002819')
    expect(page).not_to have_field('Data de Nascimennto', with: '16/03/1981')
  end
end
