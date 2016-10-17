class AddMovielensMovieToMovielensRatings < ActiveRecord::Migration
  def change
    add_reference :movielens_ratings, :movielens_movie, index: true, foreign_key: true
  end
end
