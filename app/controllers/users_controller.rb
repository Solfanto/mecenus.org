class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.country = params[:user][:country]
    @user.display_name = params[:user][:display_name]
    @user.twitter_username = params[:user][:twitter_username]
    @user.facebook_username = params[:user][:facebook_username]
    @user.bio = params[:user][:bio]
    @user.location = params[:user][:location]

    if @user.save
      redirect_to profile_url
    else
      render :edit
    end
  end

  def edit_payment_settings
    if current_user.stripe_customer_id
      @card = current_user.current_card
    end
  end

  def edit_bank_account_settings
    @user = current_user
    if params[:change_bank_account].nil? && @user.stripe_account_id
      @existing_bank_account = current_user.fetch_bank_information
    end
  end

  def update_bank_account_settings
    @user = current_user
    @user.currency = params[:user][:currency]
    @user.bank_holder_name = params[:user][:bank_holder_name]
    @user.bank_account_number = params[:user][:bank_account_number]
    @user.bank_routing_number = params[:user][:bank_routing_number]
    @country = params[:user][:country]

    begin
      @user.update_bank_information(
        country: params[:user][:country], 
        currency: params[:user][:currency], 
        account_number: @user.bank_account_number, 
        routing_number: @user.bank_routing_number, 
        account_holder_type: "individual", 
        name: params[:user][:name]
      )

    rescue Stripe::InvalidRequestError => e
      flash[:alert] = "#{e.message}"
      render :edit_bank_account_settings
    else
      redirect_to bank_account_settings_url, notice: "Bank Account has been updated"
    end
  end
end
