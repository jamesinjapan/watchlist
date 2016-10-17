class MovieController < ApplicationController
  def index
    # Libraries for JSON
    require 'net/http' 
    require 'json' 
    
    @movie_id = params[:m]
    
    # Get JSON data from tmdb
    url = "https://api.themoviedb.org/3/movie/" + @movie_id + "?api_key=553017e076c2ecd01b7bf9cdd20a6360&append_to_response=keywords,credits,recommendations,similar,reviews"
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    @m = JSON.parse(response) 
    
    # Prepare plus sign glyphicon span
    @glyphicon_plus = "<span class='glyphicon glyphicon-plus' aria-hidden='true'></span> "
    
    # Prepare poster array
    @tmdb_recommends = @m["recommendations"]["results"] + @m["similar"]["results"]
    @tmdb_recommends.sort! { |x,y| y["popularity"] <=> x["popularity"] }
    @tmdb_recommends.uniq! { |v| v["id"] }
    @tmdb_recommends.delete_if { |v| v["poster_path"] == nil } 
    params.delete :m
  end
end
