class SearchController < ApplicationController
  def index
    @projects = []
    
    queries = params[:q].downcase.tokenize
    queries.each do |query|
      @projects += Project.published.not_closed.where("LOWER(title) LIKE ?", "%#{query}%")
      @projects += Project.published.not_closed.where("LOWER(summary) LIKE ?", "%#{query}%")
    end
    @projects.uniq!
    
    @projects = Kaminari.paginate_array(@projects).page(params[:page]).per(20)
  end
end
