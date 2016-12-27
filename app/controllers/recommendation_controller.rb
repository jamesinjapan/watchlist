class RecommendationController < ApplicationController
  def convertDateFilterToDateRange(filter)
    case filter
      when "silent"
        return (1870..1926).to_a
      when "sound"
        return (1927..1939).to_a
      when "1940s"
        return (1940..1949).to_a
      when "1950s"
        return (1950..1959).to_a
      when "1960s"
        return (1960..1969).to_a
      when "1970s"
        return (1970..1979).to_a
      when "1980s"
        return (1980..1989).to_a
      when "1990s"
        return (1990..1999).to_a
      when "2000s"
        return (2000..2009).to_a
      when "2010s"
        return (2010..2019).to_a
      when "2020s"
        return (2020..2029).to_a
    end
  end
  
  def index
    @genres = params[:g] if params[:g].present?
    @keywords = params[:k] if params[:k].present?
    @page = 1
    @page = params[:p].to_i if params[:p].present?
    p @page
    
    # Build list of years to exclude
    if params[:d].present?
      @date_filter = params[:d]
      year_blacklist = Array.new
      @date_filter.uniq.each do |date|
        year_blacklist += convertDateFilterToDateRange(date)
      end
    end
    
    @include_adult = include_adult?(user_signed_in?,current_user)
    if params[:c].present?
      @certificate_filter = params[:c]
      certificate_whitelist = Array.new
      
      if @include_adult == false
        certificate_whitelist = ["G","PG","PG-13"]
      else
        certificate_whitelist = ["G","PG","PG-13","R","NC-17","NR"]
      end
      @certificate_filter.each do |cert|
        certificate_whitelist -= [cert.upcase]
      end
    end
    
    # Build list of movie ids to recommend based on parameters given
    
    @based_on = Array.new
    if @keywords != nil 
      ActsAsTaggableOn::Tag.where(id: @keywords).each do |tag| 
        @based_on.push(tag.name)
      end
    end
    if @genres != nil
      @genres.each { |v| @based_on.push(TMDB_GENRE_LIST.select { |g| g["id"] == v.to_i }[0]["name"]) }
    end

    @recommendation_list = []
    keyword_recommendations = []
    genre_recommendations = []
    
    if @keywords != nil
      if @keywords.kind_of?(String)
        keyword_recommendations.push(Movie.tagged_with(@based_on[0]).pluck(:id))
      else
        @keywords.each_with_index do |v, i|
          keyword_recommendations[i] = Movie.tagged_with(@based_on[i]).pluck(:id)
        end
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
    if params[:m]
      @original_movie = Movie.find_by(tmdb: params[:m])
      if recommendations_full.include?(params[:m])
        recommendations_full.delete(params[:m])
      end
      params.delete(:m)
    end
    puts recommendations_full
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
    
    # Return movie data
    @recommendation_list = []
    @recommendation_list_ids = []
    @recommendation_ids.each do |v| 
      p v
      r = Movie.find(v)
      puts r.inspect
      if r.title == nil || r.release_date == nil || (@certificate_filter != nil && !(certificate_whitelist.include?(r.certification))) || (@date_filter != nil && year_blacklist.include?(r.release_date.year))
        next
      end
      @recommendation_list.push(r)
      @recommendation_list_ids.push(r.id)
    end
    
    # Paginate
    @total_pages = @recommendation_list_ids.count / 12
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
    
    @recommendation_ids = @recommendation_list_ids[lower_bound..upper_bound]
    @recommendation_list = @recommendation_list[lower_bound..upper_bound]
    
    puts params
    puts @certificate_filter
    puts @date_filter
    puts year_blacklist if year_blacklist != nil
    puts certificate_whitelist if certificate_whitelist != nil
  end
end
