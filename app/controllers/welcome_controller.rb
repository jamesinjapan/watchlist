class WelcomeController < ApplicationController
  def index
    
    # Redirect if movie or search term parameters are available
    if params[:m].present?
      redirect_to movie_index_path + "?m=" + params[:m]
    elsif params[:t].present?
      redirect_to search_index_path + "?t=" + params[:t]
    end
    
    include_adult = include_adult?(user_signed_in?,current_user)
    
    @recommendations = Array.new
    
    if user_signed_in? && current_user.recommendations != nil
      @recommendations = Movie.where(id: current_user.recommendations.split(","))
    else
      url = "https://api.themoviedb.org/3/discover/movie?api_key=" + TMDB_API_KEY + "&language=en-US&sort_by=popularity.desc&include_adult=" + include_adult.to_s + "&include_video=false&release_date.lte=" + (Time.now - 1.year).strftime("%Y-%m-%d") + "&page=1"
      uri = URI(url) 
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      
      result["results"].each do |v|
        record = {
          tmdb: v["id"],
          title: v["title"],
          release_date: v["release_date"],
          poster_path: TMDB_IMG_BASE + TMDB_POSTER_SIZES[4] + v["poster_path"]
        }
        @recommendations.push(record)
      end
    end
    
  end
  
  def update_db
    movie_details_creator(params[:m], true)  
    redirect_to movie_index_path + "?m=" + params[:m]
  end
  
end
