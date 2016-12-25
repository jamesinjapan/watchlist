class MovieController < ApplicationController
  
  def index
    @movie_id = params[:m]
    @current_movie = Movie.find_by(tmdb: @movie_id)
    
    @movie_details = movie_details_creator(@movie_id,true)
    
    if @current_movie && @current_movie.keyword_list != nil
      @keyword_list = @current_movie.keyword_list
    else
      @keyword_list = []
    end
    
    include_adult = include_adult?(user_signed_in?,current_user)
    
    # Get JSON data from tmdb
    i = 1
    @recommendation_list = []
    3.times do
      url = "https://api.themoviedb.org/3/movie/" + @movie_id + "/recommendations?api_key=" + TMDB_API_KEY + "&page=" + i.to_s
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
      if user_signed_in? && local && (local.ratings.pluck(:user_id).include?(current_user.id) || (current_user.watchlist != nil && current_user.watchlist.split(",").include?(local.id.to_s)))
        p "User Rated"
        next 
      end
      if local
        if (include_adult == false && ["G","PG","PG-13"].include?(local.certification) == true) || include_adult
          @recommendations.push(poster_path: local.poster_path, title: local.title, release_date: local.release_date, tmdb: local.tmdb) 
        end
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
      
      # Get current user's existing rating record
      if current_movie != nil
        if current_movie.ratings != nil 
          if current_movie.ratings.find_by(user_id: current_user.id) != nil
            user_rating = current_movie.ratings.find_by(user_id: current_user.id)
          end
        end
      end
      
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
    params[:id] = Movie.find_by(tmdb: params[:m]).id.to_s
    remove_from_watchlist if user_signed_in?
  end
  
  # Add movie to the user's watchlist
  def add_to_watchlist
    # If user is not signed in or parameters are missing, do nothing
    if user_signed_in? && params[:id].present?
      if current_user.watchlist == nil
        current_user.watchlist = params[:id].to_s
      else
        current_user.watchlist += "," + params[:id].to_s
      end
      current_user.save!
      puts "Record updated"
    else
      flash[:danger] = "Error adding to watchlist"
      redirect_to movie_index_path + "?m=" + params[:m]
    end
    
    # Update user recommendations in another thread
    update_recommendations_list_in_background(current_user) if user_signed_in?
    redirect_to movie_index_path + "?m=" + params[:m]
  end
  
  def remove_from_watchlist
    puts "REMOVE FROM WATCHLIST: " + params[:id]
    # If user is not signed in or parameters are missing, do nothing
    if user_signed_in? && params[:id] != nil && current_user.watchlist != nil
      if current_user.watchlist.include?(",")
        watchlist = current_user.watchlist
        watchlist = watchlist.split(",")
        watchlist.delete(params[:id])
        current_user.watchlist = watchlist.join(",")
      else 
        current_user.watchlist = nil if current_user.watchlist == params[:id]
      end
      current_user.save!
      puts "Record updated"
      update_recommendations_list_in_background(current_user)
    else
      flash[:danger] = "Error removing from watchlist"
    end
    
    redirect_to movie_index_path + "?m=" + params[:m]
  end
  
  # Update user's frontpage welcome list in background to reduce impact on user
  def update_recommendations_list_in_background(user)
    if user && user.ratings.count > 0 && current_user.watchlist.split(",").count <= 5
      include_adult = include_adult?(true,user)
      recommendations_list = []
      good_ratings = user.ratings.order(id: :desc).where(rating: "2").pluck(:movie_id)
      good_ratings = good_ratings + user.watchlist.split(",") if user.watchlist != nil
      good_ratings.each do |rating|
        other_user_rating = Rating.order(id: :desc).where("rating = ? AND movie_id = ? AND user_id <> ?","2",rating,user.id).take(20)
        other_user_rating.each do |other_rating|
          other_user = User.find(other_rating.user_id).ratings.order(id: :desc).where("rating = ? AND movie_id <> ?","2",rating).take(20)
          if other_user.count > 0
            recommendations_list << other_user.map(&:movie_id)
            break
          end
        end
        recommendations_list.compact!
        break if recommendations_list.count > 50
      end 
      recommendations_list = recommendations_list + DEFAULT_RECOMMENDATIONS
      recommendations_list = recommendations_list.flatten.uniq - user.ratings.pluck(:movie_id)
      recommendations_details = Movie.where(id: recommendations_list.uniq)
      recommendations = Array.new
      recommendations_details.each do |movie| 
        if ["G","PG","PG-13"].include?(movie.certification) == false && include_adult == false
          next
        end
        recommendations.push(movie) 
      end
      recommendations.sort! { |x,y| y.imdb_rating.to_f <=> x.imdb_rating.to_f }
      user.recommendations = recommendations.map { |movie| movie[:id]}[0..9].join(",")
      user.save!
    end
  end
  
  def add_keyword_to_movie
    
    if user_signed_in?  && params[:m].present? && params[:tt] != "" && params[:tt] != nil
      tag_text = params[:tt]
      movie = Movie.find_by(tmdb: params[:m])
      movie.keyword_list.add(tag_text)
      movie.save!
      flash[:success] = "Keyword added to movie"
    elsif user_signed_in? == false
      flash[:warning] = "You must be signed in to add a keyword"
    elsif params[:tt] == "" || @params[:tt] == nil
      flash[:warning] = "You must enter the keyword you wish to save"  
    else
      flash[:danger] = "Error adding keyword. Please try again."
    end
    
    redirect_to :back
  end
  
  def hide_keywords_from_user
    puts params
    # If user is not signed in or parameters are missing, do nothing
    if user_signed_in? && params[:k].present?
      params[:k].each do |id|
        if current_user.hidden_tags == nil
          current_user.hidden_tags = id.to_s
        else
          current_user.hidden_tags += "," + id.to_s
        end
        current_user.save!
        puts "Record updated"
      end
    else
      flash[:danger] = "Error hiding keyword"
    end
    redirect_to :back
  end
end
