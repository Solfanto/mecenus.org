class DashboardController < ApplicationController
  def index
    @records = current_user.donation_records.order("date DESC").page(params[:page])
  end
end