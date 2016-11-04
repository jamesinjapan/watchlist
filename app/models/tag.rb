class Tag < ActiveRecord::Base
  belongs_to :movie
  belongs_to :user
  belongs_to :tag_key
end
