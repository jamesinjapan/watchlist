class Movie < ActiveRecord::Base
  has_many :tags
  has_many :ratings
  has_many :tag_keys, through: :tags
end
