class MovieController < ApplicationController
  
  def index
    @movie_id = params[:m]
    @current_movie = Movie.find_by(tmdb: @movie_id)
    
    @movie_details = movie_details_creator(@movie_id,true)
    
    if @current_movie && @current_movie.tag_keys
      @keyword_list = @current_movie.tag_keys
    else
      @keyword_list = []
    end
    
    # Get JSON data from tmdb
    i = 1
    @recommendation_list = []
    3.times do
      url = "https://api.themoviedb.org/3/movie/" + @movie_id + "/similar?api_key=" + TMDB_API_KEY + "&page=" + i.to_s
      uri = URI(url) 
      response = Net::HTTP.get(uri)
      m = JSON.parse(response)
      @recommendation_list << m["results"]
      i += 1
    end
    
    # Prepare poster array
    @recommendation_list.flatten!
    @recommendation_list.compact!
    @recommendation_list.sort! { |x,y| y["popularity"] <=> x["popularity"] }
    @recommendation_list.uniq! { |v| v["id"] }
    @recommendation_list.delete_if { |v| v["poster_path"] == nil } 
    
    user_rated_tmdb = []
    
    if user_signed_in?
      user_rated = current_user.ratings.pluck(:movie_id)
      user_rated_tmdb = Movie.where(tmdb: user_rated).pluck(:tmdb)
      p user_rated_tmdb
    end
    
    @recommendations = []
    
    @recommendation_list.each do |v|
      if @recommendations.count > 10
        break
      end
      
      if v["release_date"].to_date > 6.months.ago
        next
      end
      
      local = Movie.find_by(tmdb: v["id"])
      
      if user_signed_in? && local && local.ratings.pluck(:user_id).include?(current_user.id)
        p "User Rated"
        next 
      end
      if local
        @recommendations.push(poster_path: local.poster_path, title: local.title, release_date: local.release_date, tmdb: local.tmdb)
      else
        @recommendations.push(poster_path: TMDB_IMG_BASE + TMDB_POSTER_SIZES[3] + v["poster_path"], title: v["title"], release_date: v["release_date"], tmdb: v["id"])
      end
    end
    
    # Get current user's rating of current movie
    @user_rating = ""
    if @current_movie && @current_movie.ratings
      if user_signed_in? && @current_movie.ratings.find_by(user_id: current_user.id) != nil
        @user_rating = @current_movie.ratings.find_by(user_id: current_user.id) 
      end
    end
    
  end
  
  def submit_rating
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
    # Update user recommendations in another thread
    update_recommendations_list_in_background(current_user) if user_signed_in?
    redirect_to movie_index_path + "?m=" + params[:m]
  end
  
  # Update user's frontpage welcome list in background to reduce impact on user
  def update_recommendations_list_in_background(user)
    if user && user.ratings.count > 0
      Thread.new do
        recommendations = []
      
        good_ratings = user.ratings.order(id: :desc).where(rating: "2")
        good_ratings.each do |rating|
          other_user_rating = Rating.order(id: :desc).where("rating = ? AND movie_id = ? AND user_id <> ?","2",rating.movie_id,user.id).take(20)
          other_user_rating.each do |other_rating|
            other_user = User.find(other_rating.user_id).ratings.order(id: :desc).where("rating = ? AND movie_id <> ?","2",rating.movie_id).take(20)
            if other_user.count > 0
              recommendations << other_user.map(&:movie_id)
              break
            end
          end
          recommendations.compact!
          break if recommendations.count > 50
        end
        recommendations = recommendations + DEFAULT_RECOMMENDATIONS
        recommendations = recommendations.flatten.uniq - user.ratings.pluck(:movie_id)
        recommended_movies = Movie.where(id: recommendations)
        recommendations_by_rating = []
        recommended_movies.each do |movie|
          all_ratings = movie.ratings
          recommendations_by_rating.push(id: movie.id, rating: (all_ratings.average(:rating) * 100).to_i) if all_ratings.count > 100
        end
        recommendations_by_rating.sort! { |x,y| y[:rating] <=> x[:rating] }
        user.recommendations = recommendations_by_rating.map { |movie| movie[:id]}[0..9].join(",")
        user.save!
      end
      ActiveRecord::Base.connection.close
    end
  end
end
