class AddPosterPathToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :poster_path, :string
  end
end
