class AddGbIdToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :gb_id, :string
  end
end
