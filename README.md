<div align="center"><h1 align="center"><span id="home"></span>Painel de Clientes</h1>
<p align="center">
  <a href="#sobre-o-projeto"> Sobre o Projeto </a>&nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#tecnologias">Tecnologias</a>&nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#usuarios-de-testes">Usuários</a>&nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#api">API</a>&nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#creditos">Créditos</a>&nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#supervisao">Supervisão</a>
</p>
</div>

[<img src="/public/qsd2021.png"/>](/public/qsd2021.png)

## Sobre o Projeto

Este projeto ["Painel de Clientes"](https://git-qsd.campuscode.com.br/qsd-7/projeto-final/painel-clientes) representa 25% do Projeto Final em equipes do Treinamento do programa Quero Ser Dev 7.

Integrado aos módulos [Vendas](https://git-qsd.campuscode.com.br/qsd-7/projeto-final/vendas), [Gestão de Produtos](https://git-qsd.campuscode.com.br/qsd-7/projeto-final/gestao-produtos) e [Gateway Pagamentos](https://git-qsd.campuscode.com.br/qsd-7/projeto-final/gateway-pagamentos), este projeto final é requisito indispensável para aprovação na fase de treinamento.

Desenvolvido no framework [Ruby on Rails](https://rubyonrails.org/), orientando-se por métodos ágeis, priorizando o método de desenvolvimento "Test Driven Development", user stories e backlog.

<div align="right">
  [Subir ao Início](#painel-clientes)
</div>

## Tecnologias

| Recurso | Versão |
|:---|:---:|
| Ruby | 3.0.3 |
| Ruby on Rails | 6.1.4.6 |
| Sqlite3 | 1.4 |
| devise ||
| faraday ||
| jbuilder | 2.7 |
| puma | 5.0 |
| sass-rails | 6.0 |
| webpacker | 5.0 |
| simplecov ||
| rubocop-rails ||
| capybara ||
| rack-mini-profiler | 2.0 |
| spring ||
| listen | 3.3 |
| bootsnap | 1.4.4 |


<div align="right">
  [Subir ao Início](#painel-clientes)
</div>

## Configuração e Instalação

### Instale primeiro as gems necessárias
```
bundle install
```

### Instale também o webpacker
```
rails webpacker:install
```

### Configure o Banco de Dados
```
rails db:migrate
```

### Para subir o servidor
```
rails s -p 3004
```

<div align="right">
  [Subir ao Início](#painel-clientes)
</div>

## Usuários de Testes

### Cliente - Teste
```
E-mail: filipe@campus.com
Senha: 123456
```

### Administrador - Teste
```
Para acessar o painel de Administradores siga pelo link
http://localhost:3004/admins/sign_in 

E-mail: joao@locaweb.com.br
Senha: 123456
```

<div align="right">
  [Subir ao Início](#painel-clientes)
</div>

# API
## Confirmação de Pagamento

### Requisição: 
```
 PATCH /api/v1/orders/payment 
```

### Parâmetros:
```json
{
  "order_code": "123456",
  "total_charge": "100",
  "status": "paid"
}
```
### Resposta:
```json
 Status: 200 (Sucesso)

{"Status do pedido alterado com sucesso"}
```
### Resposta:
```json
 Status: 404 (Não encontrado)

{"alert": "Pedido não encontrado"}
```

<div align="right">
  [Subir ao Início](#painel-clientes)
</div>


### Créditos
- [Anderson Aguiar](https://git-qsd.campuscode.com.br/andersondeaguiardeoliveira)
- [Andrei Bissolotti](https://git-qsd.campuscode.com.br/andreibissolotti)
- [Filipe Machado](https://git-qsd.campuscode.com.br/Filipeem)
- [Ruan Afonso](https://git-qsd.campuscode.com.br/pourroy)
- [Victor de Oliveira](https://git-qsd.campuscode.com.br/v1t4o)

<div align="right">
  [Subir ao Início](#painel-clientes)
</div>

### Supervisão
- [João Almeida](https://git-qsd.campuscode.com.br/joaorsalmeida)


<div align="right">
  [Subir ao Início](#painel-clientes)
</div>

