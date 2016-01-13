class DonationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @donations = current_user.donations
    @incoming_payments = []
    @donations.each do |donation|
      next unless donation.enabled
      last_payment = donation.payments.order("processed_at DESC").first
      if last_payment&.processed_at&.year == Time.now.year && last_payment&.processed_at&.month == Time.now.month 
        next_payment_time = Time.now.change(day: donation.processing_day).next_month
      elsif Time.now.change(day: donation.processing_day) < Time.now
        next_payment_time = Time.now.change(day: donation.processing_day).next_month
      else
        next_payment_time = Time.now.change(day: donation.processing_day)
      end
      @incoming_payments << Payment.new(
        project_id: donation.project_id, 
        donation_id: donation.id, 
        amount: donation.amount, 
        currency: donation.currency, 
        processed_at: next_payment_time
      )
    end

    @processed_payments = current_user.payments.where("processed_at <= NOW()").order("created_at DESC").page(params[:page])
  end

  def new
    @project = Project.published.not_closed.find_by!(name: params[:project_name])
    @donation = current_user.donations.build
    @donation.project = @project
    @donation.amount = params[:amount]

    if current_user.stripe_customer_id
      @card = current_user.current_card
    end
  end

  def edit
    @project = Project.published.not_closed.find_by!(name: params[:project_name])
    @donation = current_user.donations.where(project_id: @project.id).first
    if @donation.nil?
      @donation = current_user.donations.build(project_id: @project.id)
      @donation.amount = 1
    end
  end

  def create
    @project = Project.published.not_closed.find_by!(name: params[:project_name])
    if current_user.donate_to(@project, params[:donation][:amount])
      redirect_to project_url(@project.name), notice: "Your donation has been registered."
    else
      render :new
    end
  end

  def cancel
    @project = Project.published.not_closed.find_by!(name: params[:project_name])
    current_user.cancel_donation_for(@project)

    redirect_to project_url(@project.name), notice: "Your monthly donation has been cancelled."
  end
end