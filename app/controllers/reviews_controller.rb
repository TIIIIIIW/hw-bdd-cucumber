class ReviewsController < ApplicationController
    before_filter :has_moviegoer_and_movie, :only => [:new, :create]
    protected
    def has_moviegoer_and_movie
        unless current_moviegoer
            flash[:warning] = 'You must be logged in to create a review.'
            redirect_to :back
        end
        unless (@movie = Movie.find(params[:movie_id]))
            flash[:warning] = 'Review must be for an existing movie.'
            redirect_to movies_path
        end
    end
  
    public
    def new
        # exist_review = current_moviegoer.reviews.find_by(movie_id: params[:movie_id])
        # if exist_review
        #     redirect_to edit_movie_review_path(@movie, exist_review)
        # end
        # @review = @movie.reviews.build
    end
  
    def create
        # since moviegoer_id is a protected attribute that won't get
        # assigned by the mass-assignment from params[:review], we set it
        # by using the << method on the association.  We could also
        # set it manually with review.moviegoer = @current_user.
        current_moviegoer.reviews << @movie.reviews.build(review_params)
        redirect_to movie_path(@movie)
    end
  
    def edit
        @movie = Movie.find params[:movie_id]
        @review = Review.find params[:id]
    end
  
    def update
        @movie = Movie.find params[:movie_id]
        @review = Review.find params[:id]
        @review.update_attributes!(review_params)
        flash[:notice] = "#{@movie.title} review was successfully updated."
        redirect_to movie_path(@movie)
    end

    def destroy
        @movie = Movie.find params[:movie_id]
        @review = Review.find params[:id]
        @review.destroy
        flash[:notice] = "Review : '#{ @review.comments}' deleted."
        redirect_to movie_path(@movie)
    end
  
    private
    def review_params
        params.require(:review).permit(:potatoes, :comments, :moviegoer, :movie)
    end
  end