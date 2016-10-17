class CreateMovielensTags < ActiveRecord::Migration
  def change
    create_table :movielens_tags do |t|
      t.string :tag
    end
    add_index :movielens_tags, :tag, :name => 'tag_ix'
  end
end
