class AddCertificationToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :certification, :string
  end
end
