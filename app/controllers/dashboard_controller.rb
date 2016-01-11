class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @records = current_user.donation_records.order("date DESC").page(params[:page])
    @balance = current_user.computed_balance
    @transfered_amount = current_user.computed_transfered_amount
  end
end