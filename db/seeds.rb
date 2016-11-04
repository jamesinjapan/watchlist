# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

=begin
# Seed Movielens Movies data
filename = 'movies.csv'
if File.exist?(filename) && File.exist?(filename)
  i = 0
  CSV.foreach(filename) do |row|
    genres = []
    if row[1] != "(no genres listed)"
      if row[1].include?("|") == false
        if row[1] == "Sci-Fi"
          row[1] = "Science Fiction"
        end
        if TMDB_GENRE_LIST.map{|m| m["name"] }.include?(row[1])
          genres.push(TMDB_GENRE_LIST.select { |m| m["name"] == row[1]}[0]["id"])
        end
      else
        row[1].split("|").each do |v|
          if v == "Sci-Fi"
            v = "Science Fiction"
          end
          if TMDB_GENRE_LIST.map{|m| m["name"] }.include?(v)
            genres.push(TMDB_GENRE_LIST.select { |m| m["name"] == v}[0]["id"])
          end
        end
      end
    end
    
    if i != 0
      record = Movie.new(
        :title => row[0].encode!('UTF-8', 'UTF-8', :invalid => :replace), 
        :genres => genres.join(","),
        :imdb => row[2],
        :tmdb => row[3]
      )
      record.save!
    end
    i += 1
  end
end
=end

# Seed Users to match max user id in Movielens dataset

(220673..247753).each do |i|
  name = Faker::Internet.user_name
  user = User.new(
    name: name,
    email: name + i.to_s + "@example.com",
    password: 'test123',
    password_confirmation: 'test123'
  )
  user.save!

end

=begin
# Seed Movielens Tags labels data
filename = 'tagkeys.csv'
if File.exist?(filename) && File.exist?(filename)
  i = 0
  CSV.foreach(filename, encoding: 'iso-8859-1') do |row|
    if i != 0
      tag_text = ""
      if row[0].bytes.map {|v| v>127 }.include?(true)
        tag_text = "(deleted)"
      else
        tag_text = row[0]
      end
      record = TagKey.new(
        :tag_text => tag_text
      )
      record.save!
    end
    i += 1
  end
end

# Seed Movielens Tags data
filename = 'tags.csv'
if File.exist?(filename) && File.exist?(filename)
  i = 0
  CSV.foreach(filename) do |row|
    if i != 0
      record = Tag.new(
        :tag_key_id => row[0], 
        :user_id => row[1],
        :movie_id => row[2]
      )
      record.save!
    end
    i += 1
  end
end


# Seed Movielens Ratings data
filename = 'ratings.csv'
if File.exist?(filename) && File.exist?(filename)
  i = 0
  CSV.foreach(filename) do |row|
    if i != 0
      record = Rating.new(
        :rating => row[0], 
        :movie_id => row[1],
        :user_id => row[2]
      )
      record.save!
    end
    i += 1
  end
end
=end