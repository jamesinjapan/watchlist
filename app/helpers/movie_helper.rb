module MovieHelper
  def ratingChecked?(rating)
    @user_rating.rating == rating rescue nil
  end
  
end
