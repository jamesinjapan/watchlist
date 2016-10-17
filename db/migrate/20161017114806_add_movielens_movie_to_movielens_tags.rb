class AddMovielensMovieToMovielensTags < ActiveRecord::Migration
  def change
    add_reference :movielens_tags, :movielens_movie, index: true, foreign_key: true
  end
end
