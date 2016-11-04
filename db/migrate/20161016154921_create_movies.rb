class CreateMovies < ActiveRecord::Migration
  def change
    create_table "movies", force: :cascade do |t|
      t.string "title"
      t.string "genres"
      t.string "imdb"
      t.string "tmdb"
    end
  end
end