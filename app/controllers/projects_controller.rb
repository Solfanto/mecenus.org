class ProjectsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :posts, :sponsors]

  def index
    @projects = current_user.created_projects
  end

  def show
    @project = current_user&.created_projects&.find_by(name: params[:name]) || Project.published.not_closed.find_by!(name: params[:name])
    @donation = current_user ? current_user.donations.where(project_id: @project.id).first : nil
    @donation ||= Donation.new(amount: 1)
  end

  def new
    @step = (params[:step] || 1).to_i
    if @step == 2
      # set project (type, banner, )
      if params[:project_name]
        @project = current_user.created_projects.find_by!(name: params[:project_name])
      else
        @project = current_user.created_projects.build
      end
      render :new_step2
    elsif @step == 3
      # set bank transer info
      @user = current_user
      @project = current_user.created_projects.find_by!(name: params[:project_name])
      if Rails.application.config.stage == :alpha
        @project.country = "US"
        @user.bank_account_number = "000123456789"
        @user.bank_routing_number = "110000000"
      end
      if params[:change_bank_account].nil? && @user.stripe_account_id
        @existing_bank_account = current_user.fetch_bank_information
      end
      render :new_step3
    elsif @step == 4
      # confirmation
      @project = current_user.created_projects.find_by!(name: params[:project_name])
      render :new_step4
    else
      # set profile (display name, twitter, FB, github, youtube, website)
      # 
      @user = current_user
      render :new_step1
    end
  end

  def create
    @step = params[:step].to_i
    if @step == 1
      @user = current_user
      @user.creating_new_project = true
      @user.assign_attributes(params.require(:user).permit(
        :country, :display_name, :twitter_username, :facebook_username, :bio, :location
      ))

      if @user.save
        redirect_to new_project_url(step: @step + 1, project_name: params[:project_name])
      else
        render :new_step1
      end
    elsif @step == 2
      @project = current_user.created_projects.build(params.require(:project).permit(
        :name, :title, :summary, :description, :license, :license_url, :url, :repo_url, :readme_url
      ))
      if @project.save
        redirect_to new_project_url(step: @step + 1, project_name: @project.name)
      else
        render :new_step2
      end
    elsif @step == 3
      @user = current_user
      @user.assign_attributes(params.require(:user).permit(
        :currency, :bank_holder_name, :bank_account_number, :bank_routing_number
      ))
      @project_name = params[:project_name]
      @project = current_user.projects.find_by!(name: params[:project_name])
      @project.country = params[:user][:country]
      @project.save

      begin
        @user.update_bank_information(
          country: @project.country, 
          currency: params[:user][:currency], 
          account_number: @user.bank_account_number, 
          routing_number: @user.bank_routing_number, 
          account_holder_type: "individual", 
          name: params[:user][:name]
        )

      rescue Stripe::InvalidRequestError => e
        flash[:alert] = "#{e.message}"
        render :new_step3
      else
        if @user.save
          redirect_to new_project_url(step: @step + 1, project_name: params[:project_name])
        else
          render :new_step3
        end
      end
    elsif @step == 4
      @project = current_user.created_projects.find_by!(name: params[:project_name])
      if params[:save_draft] == "true"
        redirect_to root_url
      else 
        if @project.publish
          redirect_to project_url(@project.name)
        else
          render :new_step4
        end
      end
    end
  end

  def edit
    @project = current_user.created_projects.find_by!(name: params[:name])
  end

  def update
    @project = current_user.projects.find_by(name: params[:name])
    @project.assign_attributes(params.require(:project).permit(
      :name, :title, :summary, :description, :license, :license_url, :url, :repo_url, :readme_url
    ))
    if @project.save
      redirect_to :back, notice: "The project information has been updated."
    else
      render :edit
    end
  end

  def publish
    @project = current_user.projects.find_by(name: params[:name])
    if @project.publish
      redirect_to :back, notice: "Your project has been published."
    else
      redirect_to :back, alert: "The project couldn't be published. Please check that all information is correct.\n(#{@project.errors.full_messages.to_sentence})"
    end
  end

  def sponsors
    @project = current_user&.created_projects&.find_by(name: params[:project_name]) || Project.published.not_closed.find_by!(name: params[:project_name])
    @sponsors = @project.sponsors
    @donation = current_user ? current_user.donations.where(project_id: @project.id).first : nil
    @donation ||= Donation.new(amount: 1)
  end

  def follow
    @project = Project.published.not_closed.find_by!(name: params[:project_name])
    current_user.follow(@project)

    respond_to do |format|
      format.html { redirect_to :back }
      format.json {
        render json: {
          id: @project.id,
          type: @project.class.name.downcase,
          action: 'follow',
          success: true
        }
      }
    end
  end

  def unfollow
    @project = Project.find_by!(name: params[:project_name])
    current_user.unfollow(@project)
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json {
        render json: {
          id: @project.id,
          type: @project.class.name.downcase,
          action: 'unfollow',
          success: true
        }
      }
    end
  end

  def close
    @project = current_user.created_projects.find_by!(name: params[:name])
  end

  def destroy
    @project = current_user.created_projects.find_by!(name: params[:name])
    @project.close
    redirect_to project_url(@project.name), alert: "Your project has been closed."
  end

  def reopen
    @project = current_user.created_projects.find_by!(name: params[:name])
    @project.reopen
    redirect_to project_url(@project.name), notice: "Your project has been reopened!"
  end
end
