class PaymentsController < ApplicationController
  before_action :authenticate_user!
  
  def index

  end

  def create
    current_user.add_payment_method(provider: params[:provider].to_sym, card: {
      exp_month: params[:exp_month],
      exp_year: params[:exp_year],
      number: params[:card_number],
      cvc: params[:cvc],
      name: params[:name],
      address_city: params[:address_city],
      address_country: params[:address_country],
      address_line1: params[:address_line1],
      address_line2: params[:address_line2],
      address_state: params[:address_state],
      address_zip: params[:address_zip]
    })
  rescue Stripe::CardError => e
    render json: e.json_body, status: 422
  else
    if current_user.stripe_customer_id
      render json: {status: 'ok'}
    else
      render json: {error: {message: "Unknown Error"}}, status: 422
    end
  end
end
