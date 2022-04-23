require 'rails_helper'

describe 'visitante cria um novo cliente' do
  it 'através da página inicial' do
    visit root_path
    click_on 'Criar conta'
    fill_in 'Nome',	with: 'Cliente1'
    fill_in 'Email',	with: 'cliente@contato.com'
    fill_in 'CPF',	with: '00000000000'
    fill_in 'Telefone',	with: '51 515151515'
    fill_in 'Endereço',	with: 'Rua do teste'
    fill_in 'Cidade',	with: 'Porto Alegre'
    fill_in 'Estado',	with: 'RS'
    fill_in 'Razão Social',	with: ''
    fill_in 'Data de Nascimento',	with: '16/03/1981'
    fill_in 'Senha',	with: '123456'
    fill_in 'Confirme sua senha',	with: '123456'
    click_on 'Cadastrar'
    click_on 'Perfil'

    expect(page).to have_text('Cliente1')
    expect(find_field('Nome').value).to eq 'Cliente1'
    expect(find_field('Email').value).to eq 'cliente@contato.com'
    expect(find_field('CPF').value).to eq '00000000000'
  end

  it 'Sem e-mail' do
    visit root_path
    click_on 'Criar conta'
    fill_in 'Nome',	with: 'Cliente1'
    fill_in 'CPF',	with: '00000000000'
    fill_in 'Telefone',	with: '51 515151515'
    fill_in 'Endereço',	with: 'Rua do teste'
    fill_in 'Cidade',	with: 'Porto Alegre'
    fill_in 'Estado',	with: 'RS'
    fill_in 'Razão Social',	with: ''
    fill_in 'Data de Nascimento',	with: '16/03/1981'
    fill_in 'Senha',	with: '123456'
    fill_in 'Confirme sua senha',	with: '123456'
    click_on 'Cadastrar'

    expect(page).to have_css('li', text: 'Email não pode ficar em branco')
    expect(page).not_to have_css('p', text: 'Bem vindo! Você realizou seu registro com sucesso.')
  end
end
