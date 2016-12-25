class KeywordController < ApplicationController
  def unhide_keyword_from_user
    if user_signed_in? && params[:k].present?
      new_hidden_tags = current_user.hidden_tags.split(",")
      new_hidden_tags.delete(params[:k])
      if new_hidden_tags == []
        current_user.hidden_tags = nil
      else
        current_user.hidden_tags = new_hidden_tags.join(",")
      end
      current_user.save!
      puts "Record updated"
    else
      flash[:danger] = "Error unhiding keyword"
    end
    redirect_to :back
  end
end
