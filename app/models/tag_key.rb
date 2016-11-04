class TagKey < ActiveRecord::Base
  has_many :tags
  has_many :movies, through: :tags
end
