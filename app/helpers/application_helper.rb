module ApplicationHelper
  
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
  def recommendations_by_tmdb_id(list, user)
    Movie.where(tmdb: list).ids - user.ratings.pluck(:movie_id)
  end
end
