class MovielensMovie < ActiveRecord::Base
  has_many :movielens_tags
  has_many :movielens_ratings
end
