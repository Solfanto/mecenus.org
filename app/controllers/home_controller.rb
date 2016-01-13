class HomeController < ApplicationController
  def index
    @posts = Post.where("project_id IN (?)", current_user.followed_project_ids)

    if @posts.count == 0
      @projects = Project.published.not_closed.includes(:user).last(10)
    end
  end
end
