class MoviesController < ApplicationController

  def index
  end
  
  def new
    @movie  = Movie.new
    @genres = Genre.all
  end
  
  def create
    Movie.create! \
      create_params.merge genres: Genre.find(params[:genres])
    
    redirect_to movies_path
  end
  
private

  def create_params
    params[:movie].permit :title, :release_year, :genres
  end
  
end