class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @project = Project.published.find_by!(name: params[:project_name])
    @posts = @project.posts.order("created_at DESC").page(params[:page])
    @donation = current_user ? current_user.donations.where(project_id: @project.id).first : nil
    @donation ||= Donation.new(amount: 1)
  end

  def show
    @project = Project.published.find_by!(name: params[:project_name])
    @post = @project.posts.find_by!(name: params[:name])
    @donation = current_user ? current_user.donations.where(project_id: @project.id).first : nil
    @donation ||= Donation.new(amount: 1)
  end

  def new
    @project = current_user.created_projects.find_by!(name: params[:project_name])
    @post = Post.new
  end

  def create
    @project = current_user.created_projects.find_by!(name: params[:project_name])
    @post = Post.new
    @post.project = @project
    @post.user = current_user
    @post.title = params[:post][:title]
    @post.content = params[:post][:content]
    if @post.save
      redirect_to project_posts_url(@project.name)
    else
      render :new
    end
  end

  def edit
    @project = current_user.created_projects.find_by!(name: params[:project_name])
    @post = @project.posts.find_by!(name: params[:name])
  end

  def update
    @project = current_user.created_projects.find_by!(name: params[:project_name])
    @post = @project.posts.find(params[:id])
    @post.project = @project
    @post.user = current_user
    @post.title = params[:post][:title]
    @post.content = params[:post][:content]
    if @post.save
      redirect_to project_posts_url(@project.name)
    else
      render :edit
    end
  end

  def destroy
    @project = current_user.created_projects.find_by!(name: params[:project_name])
    @post = @project.posts.find(params[:id])
    @post.destroy
    redirect_to project_posts_url(@project.name)
  end
end