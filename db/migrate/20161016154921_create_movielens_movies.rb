class CreateMovielensMovies < ActiveRecord::Migration
  def change
    create_table "movielens_movies", force: :cascade do |t|
      t.string "title"
      t.string "genres"
      t.string "imdb"
      t.string "tmdb"
    end
    add_index "movielens_movies", ["imdb"], name: "imdb_ix"
    add_index "movielens_movies", ["title"], name: "title_ix"
    add_index "movielens_movies", ["tmdb"], name: "tmdb_ix"
  end
end