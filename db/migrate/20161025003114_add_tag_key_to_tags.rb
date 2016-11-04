class AddTagKeyToTags < ActiveRecord::Migration
  def change
    add_reference :tags, :tag_key, index: true, foreign_key: true
  end
end
