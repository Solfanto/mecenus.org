class SearchController < ApplicationController
  def index
    @projects = Project.published.not_closed.where("LOWER(title) LIKE ?", "%#{params[:q]}%")
  end
end
