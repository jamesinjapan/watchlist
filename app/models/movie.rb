class Movie < ActiveRecord::Base
  has_many :ratings
  
  acts_as_taggable_on :keywords
end