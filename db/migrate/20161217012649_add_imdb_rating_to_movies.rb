class AddImdbRatingToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :imdb_rating, :string
  end
end
