class AddAvailabilityOnlineToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :availability_online, :boolean
  end
end
