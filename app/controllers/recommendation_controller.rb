class RecommendationController < ApplicationController
  def index
    require 'net/http' 
    require 'json' 
    
    @genres = params[:g] if params[:g].present?
    @keywords = params[:k] if params[:k].present?
    @page = 1
    @page = params[:p].to_i if params[:p].present?
    p @page
    # Build list of movie ids to recommend based on parameters given

    @recommendation_list = []
    keyword_recommendations = []
    genre_recommendations = []
    
    if @keywords != nil
      @keywords.each_with_index do |v, i|
        keyword_recommendations[i] = Tag.where(tag_key_id: v).pluck(:movie_id)
      end
      recommendation_ids_k = keyword_recommendations.max_by(&:length)
      keyword_recommendations -= [recommendation_ids_k]
      recommendation_ids_k.zip(*keyword_recommendations).flatten.compact
    end
    
    if @genres != nil
      @genres.each_with_index do |v, i|
        genre_recommendations[i] = Movie.where("genres LIKE ?","%#{v}%").pluck(:id)
      end
      recommendation_ids_g = genre_recommendations.max_by(&:length)
      genre_recommendations -= [recommendation_ids_g]
      recommendation_ids_g.zip(*genre_recommendations).flatten.compact
    end
    
    if @keywords != nil && @genres != nil
      recommendations_full = recommendation_ids_g.zip(recommendation_ids_k).flatten.compact 
    elsif @keywords != nil 
      recommendations_full = recommendation_ids_k
    elsif @genres != nil
      recommendations_full = recommendation_ids_g
    else
      recommendations_full = []
    end
    
    # Remove movie user began search with
    
    @original_movie = Movie.find_by(tmdb: params[:m])
    if recommendations_full.include?(params[:m])
      recommendations_full.delete(params[:m])
    end

    
    # Move movies matching multiple criteria to front of list
    
    recommendations_dupes = recommendations_full.detect{ |v| recommendations_full.count(v) > 1 }
    
    unless recommendations_dupes.kind_of?(Array)
      recommendations_dupes = [recommendations_dupes]
    end
    
    recommendations_deduped = recommendations_full.uniq - recommendations_dupes.to_a.uniq
    
    @recommendation_ids = recommendations_dupes.uniq + recommendations_deduped
    
    @recommendation_ids.compact!
    
    # Remove movies the user has already rated
    
    if user_signed_in?
      user_rated = current_user.ratings.pluck(:movie_id)
      @recommendation_ids = @recommendation_ids - user_rated
    end
    
    # Paginate
    @total_pages = @recommendation_ids.count / 10
    @total_pages = 1000 if @total_pages > 1000
    @total_pages = 1 if @total_pages == 0
    
    if @page - 4 > 1 
      @lowest_page = @page - 4
    else
      @lowest_page = 1
    end
    
    @highest_page = (@page + 9) - (@page - @lowest_page) 
    @highest_page = @total_pages if @highest_page > @total_pages
   
    lower_bound = (@page * 12) - 12
    upper_bound = (@page * 12) - 1
    
    @recommendation_ids = @recommendation_ids[lower_bound..upper_bound]
    
    # Return movie data
    
    @recommendation_list = []
    @recommendation_ids.each do |v| 
      p v
      r = Movie.find(v)
      if r.title == nil
        next
      end
      @recommendation_list.push(r)
    end
    
  end
end
