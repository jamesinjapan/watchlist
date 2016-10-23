class MovieController < ApplicationController
  def index
    # Libraries for JSON
    require 'net/http' 
    require 'json' 
    
    @movie_id = params[:m]
    
    # Get JSON data from tmdb
    url = "https://api.themoviedb.org/3/movie/" + @movie_id + "?api_key=" + TMDB_API_KEY + "&append_to_response=keywords,credits,recommendations,similar,reviews,releases"
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    @m = JSON.parse(response) 
    
    # Prepare plus sign glyphicon span
    @glyphicon_plus = "<span class='glyphicon glyphicon-plus' aria-hidden='true'></span> "
    
    # Get JSON data from tmdb
    url = "https://www.omdbapi.com/?i=" + @m["imdb_id"]
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    @i = JSON.parse(response) 
    
    # Prepare poster array
    @tmdb_recommends = @m["recommendations"]["results"] + @m["similar"]["results"]
    @tmdb_recommends.sort! { |x,y| y["popularity"] <=> x["popularity"] }
    @tmdb_recommends.uniq! { |v| v["id"] }
    @tmdb_recommends.delete_if { |v| v["poster_path"] == nil } 
    params.delete :m
  end
end
