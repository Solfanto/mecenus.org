class WelcomeController < ApplicationController
  def index
    if current_user
      @projects = Project.featured.published.not_closed.includes(:user).last(20)
      if @projects.size > 0
        render :featured
      else
        @projects = Project.published.not_closed.includes(:user).last(20)
        render :index
      end
    else
      @projects = Project.published.not_closed.includes(:user).last(20)
      render :index
    end
  end

  def help; end

  def guidelines; end

  def terms; end

  def contribute; end

  def about; end
end
