class DonationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @donations = current_user.donations
    @incoming_payments = current_user.payments.where("processed_at > NOW()")

    @processed_payments = current_user.payments.where("processed_at <= NOW()")
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
      redirect_to project_path(@project.name), notice: "Your donation has been registered."
    else
      render :new
    end
  end

  def cancel
    @project = Project.published.not_closed.find_by!(name: params[:project_name])
    current_user.cancel_donation_for(@project)

    redirect_to @project, notice: "Your monthly donation has been cancelled."
  end
end