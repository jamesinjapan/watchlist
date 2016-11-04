class AddMovieToTags < ActiveRecord::Migration
  def change
    add_reference :tags, :movie, index: true, foreign_key: true
  end
end
