class AddWatchlistToUsers < ActiveRecord::Migration
  def change
    add_column :users, :watchlist, :string
  end
end
