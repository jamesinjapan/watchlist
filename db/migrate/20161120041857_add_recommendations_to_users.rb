class AddRecommendationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recommendations, :string
  end
end
