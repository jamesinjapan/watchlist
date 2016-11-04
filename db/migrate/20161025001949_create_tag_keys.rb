class CreateTagKeys < ActiveRecord::Migration
  def change
    create_table :tag_keys do |t|
      t.string :tag_text
    end
  end
end
