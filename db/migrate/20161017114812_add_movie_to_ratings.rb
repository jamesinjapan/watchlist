class AddMovieToRatings < ActiveRecord::Migration
  def change
    add_reference :ratings, :movie, index: true, foreign_key: true
  end
end
