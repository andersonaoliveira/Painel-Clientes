class CreditCardsController < ApplicationController
  before_action :authenticate_client!

  def index
    @client = Client.find(current_client.id)
    @credit_cards = CreditCard.where(client_id: @client.id)
  end

  def new
    if check_payment_status
      @card_banners = CardBanner.all
    else
      redirect_to credit_cards_path,
                  alert: 'Indisponível no momento, tente novamente mais tarde'
    end
  end

  def create
    card_params = get_card_params(params)
    @credit_card = CreditCard.save(card_params, current_client.eni)
    if @credit_card.nil?
      render_new('Não foi possível gravar o cartão')
    else
      redirect_to credit_cards_path, notice: 'Cartão cadastrado com sucesso'
    end
  end

  def down
    if check_payment_status
      if CreditCard.find(params[:id]).down
        redirect_to credit_cards_path, notice: 'Cartão desativado com sucesso'
      else
        redirect_to credit_cards_path, alert: 'Falha ao desativar o cartão, tente novamente mais tarde!'
      end
    else
      redirect_to credit_cards_path,
                  alert: 'Indisponível no momento, tente novamente mais tarde'
    end
  end

  def up
    card = CreditCard.find(params[:id])
    if card.up
      redirect_to credit_cards_path, notice: 'Cartão ativo com sucesso'
    else
      redirect_to credit_cards_path, alert: 'Falha ao ativar o cartão, tente novamente mais tarde!'
    end
  end

  private

  def get_card_params(params)
    card_params = params.permit(:number, :holder_name, :valid_date,
                                :nickname, :token, :security_code, :cpf, :client_id, :card_banner_id)
    card_params[:cpf] = card_params[:cpf].gsub(/[^0-9]/, '')
    card_params[:number] = card_params[:number].gsub(' ', '')
    card_params
  end

  def render_new(msg)
    @card_banners = CardBanner.all
    flash.now['alert'] = msg
    render 'new'
  end
end
