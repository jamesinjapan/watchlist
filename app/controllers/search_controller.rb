class SearchController < ApplicationController
  def index
    if params[:m].present?
      redirect_to movie_index_path + "?m=" + params[:m]
    end
  end
  
  def movieTitleLookup
    if params[:m].present?
      redirect_to movie_index_path + "?m=" + params[:m]
    else
      redirect_to search_index_path + "?t=" + params[:t]
    end
  end
  
  def movieTitleAutocomplete
    require 'net/http' 
    require 'json' 
    
    url = "https://api.themoviedb.org/3/search/movie?api_key=553017e076c2ecd01b7bf9cdd20a6360&language=en-US&query=" + params[:t]
    uri = URI(url) 
    response = Net::HTTP.get(uri)
    results = JSON.parse(response) 
    movietitle_hash = []
    results["results"].each { |v|
      if v["release_date"] == ""
        label = v["title"] + " (Unknown release)"
      else
        label = v["title"] + " (" + v["release_date"][0..3] + ")"
      end
      movietitle_hash.push(
        :label => label,
        :value => v["id"],
        :poster => v["poster_path"],
        :popularity => v["popularity"]
      )
    }
    movietitle_hash.sort_by! { |h| h[:popularity].to_f }.reverse!
    render :json => movietitle_hash
  end
end
