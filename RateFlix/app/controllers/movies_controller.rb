class MoviesController < ApplicationController
  include MoviesHelper
  def index
    @movie = Movie.new
    @movies = Movie.all
    render 'index'
  end

  def show
    @movie = Movie.find_by(id: params[:id])
    @genres = @movie.genres
    @reviews =  @movie.reviews
    @review = Review.new(user_email: params[:user_email],
                         rating: params[:rating].to_s,
                         date_published: params[:date_published],
                         comment: params[:comment],
                         movie_id: @movie.id)
    render 'show'
  end

  def create
    p "params are: "
    p params
    title = params[:movie][:title]
    @movie = Movie.find_by(title: title)
    p @movie
    if @movie
      p "movie already existed"
      redirect_to "/movies/#{@movie.id}"
    elsif
      p "searched movie is being built"
      response = search(title)
      p "response hash is: "
      p response
      @movie = Movie.create!(title: response[:title],
                         release_date: response[:release_date],
                         tmdb_id: response[:tmdb_id])
      p @movie
      genres = find_movie_genres(@movie.tmdb_id.to_s)
      build_movie_genres(movie: @movie, genres: genres)
      redirect_to "/movies/#{@movie.id}"
    else
      render json: {error: "movie failed to be found"}
    end
  end
end
