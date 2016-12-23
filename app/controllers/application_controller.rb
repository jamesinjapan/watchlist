# ApplicationController holds application-wide methods
class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected

  def configure_permitted_parameters
    added_attrs = [:email, :password, :password_confirmation, :remember_me, :adult_flag]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
  
  # Return movie details from external TMDb API
  def movie_details_from_tmdb(tmdb_id)
    url = "https://api.themoviedb.org/3/movie/" + tmdb_id + "?api_key=" + TMDB_API_KEY + "&append_to_response=keywords,recommendations,similar,release_dates"
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    return JSON.parse(response)
  end
  
  # Return movie details from external omdb API
  def movie_details_from_omdb(imdb_id)
    url = "https://www.omdbapi.com/?" + imdb_id
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    return JSON.parse(response)
  end
  
  # Return Guidebox movie id from external Guidebox API
  def movie_id_from_gb(tmdb_id)
    url = "https://api-public.guidebox.com/v1.43/US/" + GB_API_KEY + "/search/movie/id/themoviedb/" + tmdb_id
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    full_response = JSON.parse(response)
    return full_response["id"]
  end
  
  # Return Guidebox movie details from external Guidebox API
  def movie_details_from_gb(gb_id)
    url = "https://api-public.guidebox.com/v1.43/US/" + GB_API_KEY + "/movie/" + gb_id
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    return JSON.parse(response)
  end
  
  # Add or change movies in thread to reduce impact on user
  def update_db_in_background(list)
    Thread.new do
      list.each do |id|
        movie_details_creator(id,false)
      end
      ActiveRecord::Base.connection.close
    end
  end
  
  # Gather local and external data to present to user
  def movie_details_creator(tmdb_id, full)
    movie_details = { tmdb: tmdb_id }
    update_movie_keys = []
    valid_certificates = ["G", "PG", "PG-13", "R", "NC-17", "Approved"]
    
    local_data = Movie.find_by(tmdb: movie_details[:tmdb])
    new_movie_flag = false
    if local_data == nil
      new_movie_flag = true
    else
      movie_details[:id] = local_data.id
      if full
        if local_data.ratings.empty?
          movie_details[:avg_user_rating] = "Not rated yet!"
        else
          movie_details[:avg_user_rating] = local_data.ratings.average(:rating).to_f.round(1)
          movie_details[:num_user_rating] = local_data.ratings.count.inspect
        end
      end
      if local_data.certification != nil
        movie_details[:certification] = local_data.certification
      end
      if local_data.poster_path != nil
        movie_details[:poster_path] = local_data.poster_path
      end
      if local_data.imdb_rating != nil
        movie_details[:imdb_rating] = local_data.imdb_rating
      end
    end
    
    # Query tmdb api
    tmdb_data = movie_details_from_tmdb(movie_details[:tmdb].to_s)
    no_tmdb_data_flag = false
    if tmdb_data.key?("status_code")
      no_tmdb_data_flag = true
      puts "tmdb_id " + movie_details[:tmdb] + ": invalid response from tmdb api"
    else
      if tmdb_data.key?("backdrop_path") && full
        movie_details[:backdrop_path] = TMDB_IMG_BASE.to_s + TMDB_BACKDROP_SIZES.last.to_s + tmdb_data["backdrop_path"].to_s
      end
      
      if tmdb_data.key?("imdb_id") && (local_data == nil || tmdb_data["imdb_id"] != local_data.imdb)
        update_movie_keys.push(:imdb)
        movie_details[:imdb] = tmdb_data["imdb_id"]
      else
        movie_details[:imdb] = local_data.imdb
      end
      
      if tmdb_data.key?("title") && (local_data == nil || tmdb_data["title"] != local_data.title)
        update_movie_keys.push(:title)
        movie_details[:title] = tmdb_data["title"]
      else
        movie_details[:title] = local_data.title
      end
      
      if tmdb_data.key?("original_language") && full && ISO_639.search(tmdb_data["original_language"]) != []
        movie_details[:original_language] = tmdb_data["original_language"]
      end
      
      if tmdb_data.key?("original_title") && tmdb_data["original_title"] != movie_details[:title] && full
        movie_details[:original_title] = tmdb_data["original_title"]
      end
      
      if tmdb_data.key?("overview") && full
        movie_details[:overview] = tmdb_data["overview"]
      end
      
      if tmdb_data.key?("poster_path") && tmdb_data["poster_path"] != nil && full
        update_movie_keys.push(:poster_path)
        movie_details[:poster_path] = TMDB_IMG_BASE + TMDB_POSTER_SIZES[4] + tmdb_data["poster_path"]
      end
      
      if tmdb_data.key?("release_date") && (local_data == nil || tmdb_data["release_date"] != local_data.release_date)
        update_movie_keys.push(:release_date)
        movie_details[:release_date] = tmdb_data["release_date"]
      else
        movie_details[:release_date] = local_data.release_date
      end
      
      if tmdb_data.key?("runtime") && full
        movie_details[:runtime] = tmdb_data["runtime"]
      end
      
      if tmdb_data.key?("tagline") && full
        movie_details[:tagline] = tmdb_data["tagline"]
      end
      
      if tmdb_data.key?("genres")
        tmdb_genres = tmdb_data["genres"].map { |v| v["id"]}.join(",")
        if local_data == nil || tmdb_genres != local_data.genres 
          update_movie_keys.push(:genres)
          movie_details[:genres] = tmdb_genres
        else
          movie_details[:genres] = local_data.genres
        end
      end

      if tmdb_data.key?("keywords")
        tmdb_keywords = tmdb_data["keywords"]["keywords"].map { |v| v["name"]}
        p tmdb_keywords
        new_keywords = tmdb_keywords - local_data.keyword_list
        new_keywords.each do |keyword|
          local_data.keyword_list.add(keyword)
        end
        local_data.save! if new_keywords.count != 0
      end
      
      if tmdb_data["release_dates"]["results"].empty?
        puts "tmdb_id #{movie_details[:tmdb]}: tmdb release dates data available"
      else
        tmdb_data["release_dates"]["results"].each do |v|
          certificate = v["release_dates"].first["certification"]
          if v["iso_3166_1"] == "US" && valid_certificates.include?(certificate) && certificate != local_data.certification 
            update_movie_keys.push(:certification)
            movie_details[:certification] = certificate
            puts "tmdb_id #{movie_details[:tmdb]}: certificate added from tmdb"
          end
        end
      end
    end
    
    # Query omdb api
    omdb_data = movie_details_from_omdb("i=" + movie_details[:imdb].to_s)
    no_omdb_data_flag = false
    if omdb_data["Response"] == "False"
      no_omdb_data_flag = true
      puts "tmdb_id " + movie_details[:tmdb].to_s + ": invalid response from omdb api"
    else
      if valid_certificates.include?(omdb_data.key?("Rated")) && omdb_data["Rated"] != local_data.certification && omdb_date["Rated"] != movie_details[:certification]
        puts "tmdb_id #{movie_details[:tmdb]}: omdb release dates data available"
        update_movie_keys.push(:certification)
        movie_details[:certification] = omdb_data["Rated"]
        puts "tmdb_id #{movie_details[:tmdb]}: certificate added from omdb"
      end
      
      if omdb_data.key?("Director") && full && omdb_data["Director"] != "N/A"
        movie_details[:director] = omdb_data["Director"]
      end
      
      if omdb_data.key?("Writer") && full && omdb_data["Writer"] != "N/A"
        movie_details[:writer] = omdb_data["Writer"]
      end
      
      if omdb_data.key?("Actors") && full && omdb_data["Actors"] != "N/A"
        movie_details[:cast] = omdb_data["Actors"]
      end
      
      if omdb_data.key?("Plot") && tmdb_data.key?("overview") == false && full && omdb_data["Plot"] != "N/A"
        movie_details[:overview] = omdb_data["Plot"]
      end
      
      if omdb_data.key?("Awards") && full && omdb_data["Awards"] != "N/A"
        movie_details[:awards] = omdb_data["Awards"]
      end
      
      if omdb_data.key?("Poster") && tmdb_data.key?("poster_path") == false && full && omdb_data["Poster"] != "N/A"
        update_movie_keys.push(:poster_path)
        movie_details[:poster_path] = omdb_data["Poster"]
      end
      
      if omdb_data.key?("Country") && full && omdb_data["Country"] != "N/A"
        movie_details[:country] = omdb_data["Country"]
      end
      
      if omdb_data.key?("Metascore") && full && omdb_data["Metascore"] != "N/A"
        movie_details[:metascore] = omdb_data["Metascore"]
      end
      
      if omdb_data.key?("imdbRating") && omdb_data["imdbRating"] != local_data.imdb_rating
        update_movie_keys.push(:imdb_rating)
        movie_details[:imdb_rating] = omdb_data["imdbRating"]
      end
      
    end
    
=begin    
    # Query Guidebox
    no_gb_data_flag = false
    if local_data.try(:gb_id)
      movie_details[:gb_id] = local_data.gb_id
    else
      no_gb_data_flag = true
      movie_details[:gb_id] = movie_id_from_gb(movie_details[:tmdb].to_s)
      update_movie_keys.push(:gb_id)
    end
    gb_data = movie_details_from_gb(movie_details[:gb_id].to_s)
    if gb_data.key?("subscription_web_sources") && gb_data["subscription_web_sources"] != "N/A"
      movie_details[:availability_online] = true
      movie_details[:watch_online] = gb_data["subscription_web_sources"]
      update_movie_keys.push(:availability_online)
    end
=end    
    
    
    if new_movie_flag
      record = Movie.new(
        title: movie_details[:title],
        genres: movie_details[:genres],
        imdb: movie_details[:imdb],
        tmdb: movie_details[:tmdb],
        certification: movie_details[:certification],
        last_checked: Time.now,
        release_date: movie_details[:release_date],
        poster_path: movie_details[:poster_path],
        # gb_id: movie_details[:gb_id],
        # availability_online: movie_details[:availability_online],
        imdb_rating: movie_details[:imdb_rating]
      )
      record.save!
    elsif update_movie_keys != []
      update_movie_keys.each do |key|
        local_data[key] = movie_details[key]
      end
      local_data[:last_checked] = Time.now
      local_data.save! 
    end
    return movie_details
  end
  
  def include_adult?(signed_in,user)
    if signed_in && user.adult_flag
      return true
    else 
      return false
    end
  end
  
end
