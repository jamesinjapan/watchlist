# Update TMDB configuration lists from API and update database

require 'net/http' 
require 'json' 

# Set API Key
TMDB_API_KEY = "553017e076c2ecd01b7bf9cdd20a6360"

# Get image config data from tmdb
url = "https://api.themoviedb.org/3/configuration?api_key=" + TMDB_API_KEY
uri = URI(url) 
response = Net::HTTP.get(uri)
results = JSON.parse(response) 

TMDB_IMG_BASE = results["images"]["secure_base_url"]
TMDB_BACKDROP_SIZES = results["images"]["backdrop_sizes"]
TMDB_LOGO_SIZES = results["images"]["logo_sizes"]
TMDB_POSTER_SIZES = results["images"]["poster_sizes"]
TMDB_STILL_SIZES = results["images"]["still_sizes"]

# Update movie certifications data from tmdb
url = "https://api.themoviedb.org/3/certification/movie/list?api_key=" + TMDB_API_KEY
uri = URI(url) 
response = Net::HTTP.get(uri)
results = JSON.parse(response)
TMDB_CERTIFICATES = []

results["certifications"].each do |k, v|
  v.each do |c|
    TMDB_CERTIFICATES.push(country: k, certification: c["certification"], meaning: c["meaning"],order: c["order"])
  end
end

url = "https://api.themoviedb.org/3/genre/movie/list?api_key=" + TMDB_API_KEY + "&language=en-US"
uri = URI(url) 
response = Net::HTTP.get(uri)
results = JSON.parse(response) 
TMDB_GENRE_LIST = results["genres"]