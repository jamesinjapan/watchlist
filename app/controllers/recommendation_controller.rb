class RecommendationController < ApplicationController
  def index
    @genres = params[:g] if params[:g].present?
    @keywords = params[:k] if params[:k].present?
    @production_countries = params[:pc] if params[:pc].present?
    @spoken_languages = params[:sl] if params[:sl].present?
    @credits = params[:c] if params[:c].present?
    @current_movie = params[:m] if params[:m].present?
  end
end
