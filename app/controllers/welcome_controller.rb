class WelcomeController < ApplicationController
  def index
    if params[:m].present?
      redirect_to movie_index_path + "?m=" + params[:m]
    elsif params[:t].present?
      redirect_to search_index_path + "?t=" + params[:t]
    end
    
  end
  
end
