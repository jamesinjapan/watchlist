class MovieController < ApplicationController
  
  def index
    
    # Libraries for JSON
    require 'net/http' 
    require 'json' 
    
    @movie_id = params[:m]
    
    # Retrieve database records and construct object
    @current_movie = Movie.find_by tmdb: @movie_id
    
    puts "Current movie: #{@current_movie.inspect}"

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
    
    # Add new movie to db
    if @current_movie == nil
      genres = []
      @m["genres"].each do |v|
        genres.push(v["id"])
      end
      genrelist = genres.join(",")
      
      imdbID = @i["imdbID"]
      imdbID[0..1] = ""
      
      record = Movie.new(
        :title => @m["title"] + " (" + @m["release_date"][0..3] + ")", 
        :genres => genrelist,
        :imdb => imdbID,
        :tmdb => @m["id"]
      )
      record.save!
      puts "New movie in DB: #{Movie.last.inspect}"
    end
    
    @current_movie = Movie.find_by tmdb: @movie_id if @current_movie == nil
    
    # Get current user's rating of current movie
    @user_rating = ""
    if @current_movie.ratings != nil 
      if user_signed_in? && @current_movie.ratings.find_by(user_id: current_user.id) != nil
        @user_rating = @current_movie.ratings.find_by(user_id: current_user.id) 
      end
    end
  end
  
  def submitRating
    # If user is not signed in or parameters are missing, do nothing
    if user_signed_in? || params.empty?
      
      # Get movie id from DB
      movie_id = params[:m]
      current_movie = Movie.find_by(tmdb: movie_id)
      puts "Current Movie: #{current_movie.inspect}"
      
      # Get current user's existing rating record
      if current_movie != nil
        if current_movie.ratings != nil 
          if current_movie.ratings.find_by(user_id: current_user.id) != nil
            user_rating = current_movie.ratings.find_by(user_id: current_user.id)
          end
        end
      end
      puts "User Rating: #{user_rating.inspect}"
      
      rating = params[:r]
      if rating == "0" || rating == "1" || rating == "2"
        if user_rating == nil
          record = Rating.new(
            :user_id => current_user.id,
            :movie_id => current_movie.id,
            :rating => rating
          )
          record.save!
          puts "New record saved"
        else
          record = current_movie.ratings.find_by(user_id: current_user.id)
          record.rating = rating
          record.save!
          puts "Record updated"
        end
      end
    end
    params.delete :r
    redirect_to movie_index_path + "?m=" + params[:m]
  end
end
