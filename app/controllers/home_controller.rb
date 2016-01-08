class HomeController < ApplicationController
  def index
    @posts = Post.where("project_id IN (?)", current_user.followed_project_ids)
  end
end
