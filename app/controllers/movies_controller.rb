Tmdb::Api.key(ENV["Tmdb_KEY"])

class MoviesController < ApplicationController

  before_action :authenticate_moviegoer!, except: [:show, :index, :force_index_redirect]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default

    @reviews = @movie.reviews
    
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end

  def new

    @movie_title = params[:name]
    @movie_date = params[:date] || Date.today.strftime()
    @movie_url = params[:url]
    @movie_description = params[:description]

  end

  def create
    if Movie.where(title: params[:movie][:title] ).empty?
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    else
      flash[:notice] = "Movie '#{ params[:movie][:title] }' already exist."
      redirect_to movies_path
    end
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def search_tmdb

    @movie_name = params[:movie][:title]

      find_movie = Tmdb::Movie.find(@movie_name)

      if !find_movie.empty?
        
        movie = find_movie[0]
        @release_date = movie.release_date
        @name = movie.title
        @url = "https://image.tmdb.org/t/p/w500" + movie.poster_path
        @description = movie.overview
        redirect_to new_movie_path( name:@name,date:@release_date,url:@url,description:@description )

      else
        flash[:notice] = "Movie '#{@movie_name}' not found."
        redirect_to movies_path
      end
      
  end

  private

  def force_index_redirect
    if !params.key?(:ratings) || !params.key?(:sort_by)
      flash.keep
      url = movies_path(sort_by: sort_by, ratings: ratings_hash)
      redirect_to url
    end
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    Hash[ratings_list.collect { |item| [item, "1"] }]
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :url)
  end

end