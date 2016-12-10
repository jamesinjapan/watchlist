class AddLastCheckedToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :last_checked, :date
  end
end
