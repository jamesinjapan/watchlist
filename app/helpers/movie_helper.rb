module MovieHelper
  def rating_checked?(rating)
    @user_rating.rating == rating rescue nil
  end
  
end
