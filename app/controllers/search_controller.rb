class SearchController < ApplicationController
  def index
    if params[:m].present?
      redirect_to movie_index_path + "?m=" + params[:m]
    end
    
    include_adult = include_adult?(user_signed_in?,current_user)
    
    # Set current page
    @current_page = params[:p].to_i
    @current_page = 1 if params[:p] == nil
    
    # Get JSON data from tmdb
    url = "https://api.themoviedb.org/3/search/movie?api_key=553017e076c2ecd01b7bf9cdd20a6360&language=en-US&include_adult=" + include_adult.to_s + "&query=" + params[:t] + "&page=" + @current_page.to_s
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    @results = JSON.parse(response) 
    
    # Set page variables
    @total_pages = 1000
    @total_pages = @results["total_pages"] if @results["total_pages"] < 1000
    
    if @current_page - 4 > 1 
      @lowest_page = @current_page - 4
    else
      @lowest_page = 1
    end
    
    @highest_page = (@current_page + 9) - (@current_page - @lowest_page) 
    @highest_page = @total_pages if @highest_page > @total_pages
  end
  
  def movie_title_lookup
    if params[:m].present?
      redirect_to movie_index_path + "?m=" + params[:m]
    else
      redirect_to search_index_path + "?t=" + params[:t]
    end
  end
  
  def movie_title_autocomplete_local
    movietitle_hash = []
    
    localmovies = MovielensMovie.where("title LIKE '#{params[:t]}%'")
    localmovies.each { |v|
      movietitle_hash.push(title: v["title"], genres: v["genres"], imdb: v["imdb"], tmdb: v["tmdb"]
      )
    }
    
    render json: movietitle_hash
  end 
  
  def movie_title_autocomplete_remote
    movietitle_hash = []
    
    include_adult = include_adult?(user_signed_in?,current_user)
    
    url = "https://api.themoviedb.org/3/search/movie?api_key=553017e076c2ecd01b7bf9cdd20a6360&language=en-US&include_adult=" + include_adult.to_s + "&query=" + params[:t]
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    results = JSON.parse(response) 
    results["results"].each { |v|
      if v["release_date"] == ""
      else
        label = v["title"] + " (" + v["release_date"][0..3] + ")"
        movietitle_hash.push(label: label, value: v["id"].to_s, popularity: v["popularity"])
      end
      
    } 
    
    render json: movietitle_hash.sort_by { |v| v["popularity"] }
  end
end
