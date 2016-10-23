class RecommendationController < ApplicationController
  def index
    require 'net/http' 
    require 'json' 
    
    @genres = params[:g] if params[:g].present?
    @keywords = params[:k] if params[:k].present?
    @production_countries = params[:pc] if params[:pc].present?
    @spoken_languages = params[:sl] if params[:sl].present?
    @credits = params[:c] if params[:c].present?
    @current_movie = params[:m] if params[:m].present?
    
    @recommendation_list = []

    url = "https://api.themoviedb.org/3/discover/movie?api_key=" + TMDB_API_KEY + "&language=en-US&sort_by=popularity.desc&page=1"
    url = url + "&with_genres=" + @genres.join(",") if @genres != nil 
    url = url + "&with_keywords=" + @keywords.join(",") if @keywords != nil 
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    results = JSON.parse(response) 
    @disc = results["results"]
    results["results"].each do |v|
      v["source"] = "discovery"
      @recommendation_list.push(v.slice("id","title","release_date","poster_path","genre_ids", "vote_count", "source", "popularity", "overview"))
    end

    if @genres != nil 
      url = "https://api.themoviedb.org/3/genre/" + @genres.join("+") + "/movies?api_key=" + TMDB_API_KEY
      uri = URI(url) 
      response = Net::HTTP.get(uri)
      results = JSON.parse(response) 
      results["results"].each do |v|
        v["source"] = "genre"
        @recommendation_list.push(v.slice("id","title","release_date","poster_path","genre_ids", "vote_count", "source", "popularity", "overview"))
      end
    end
    
    if @keywords != nil 
      url = "https://api.themoviedb.org/3/keyword/" + @keywords.join("+") + "/movies?api_key=" + TMDB_API_KEY
      uri = URI(url) 
      response = Net::HTTP.get(uri)
      results = JSON.parse(response) 
      results["results"].each do |v|
        v["source"] = "keyword"
        @recommendation_list.push(v.slice("id","title","release_date","poster_path","genre_ids", "vote_count", "source", "popularity", "overview"))
      end
    end

    @recommendation_list.delete_if { |v| v["poster_path"] == nil } 
    @recommendation_list.delete_if { |v| v["id"].to_s == @current_movie.to_s } 
    @recommendation_list.delete_if { |x| (@genres - x["genre_ids"].map { |v| v.to_s}).count == @genres.count } if @genres != nil 
    @recommendation_list.uniq! { |v| v["id"] }
    @recommendation_list.sort! { |x,y| y["popularity"] <=> x["popularity"] }
    @recommendation_list.sort! { |x,y| (@genres - x["genre_ids"].map { |v| v.to_s}).count <=> (@genres - y["genre_ids"].map { |v| v.to_s}).count } if @genres != nil 
  end
end
