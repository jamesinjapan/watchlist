class CreateMovielensRatings < ActiveRecord::Migration
  def change
    create_table :movielens_ratings do |t|
      t.string :rating
    end
  end
end
