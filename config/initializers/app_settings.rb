# Set API Key
TMDB_API_KEY = ApiKey.find_by(service_name: "tmdb").key

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

# Default recommendation list

recommendation_ids = Rating.order(id: :desc).where(rating: "2").first(50).map(&:movie_id)
recommendations = Movie.find(recommendation_ids)
DEFAULT_RECOMMENDATIONS = Array.new
recommendations.each { |movie| DEFAULT_RECOMMENDATIONS.push(movie.id) if ["G","PG","PG-13"].include?(movie.certification) }

# Guidebox 

GB_API_KEY = ApiKey.find_by(service_name: "gb").key