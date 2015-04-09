class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings =  Movie.pluck(:rating).uniq
    @selected_ratings = []
    flash.keep

    unless params[:ratings].nil?
      session[:ratings] = params[:ratings]
      keys = params[:ratings].keys
      keys.each do |key|
        @selected_ratings << key.to_s
      end
    else
      if session[:ratings].nil?
         @all_ratings.each do |one_rating| 
            @selected_ratings << one_rating
         end
       else
        keys = session[:ratings].keys
        keys.each do |key|
          @selected_ratings << key.to_s
        end
       end
    end

    if params[:sort].nil? #Sem requisicao de filtro
      if session[:header].nil? # sem filtro salvo
        @movies = Movie.where(rating: @selected_ratings)
      else
        redirect_to movies_path(:sort => session[:header], :rating => @selected_ratings)
        #if session[:header] == "title"
         # redirect_to movies_path(:sort => "title")
          #@movies = Movie.where(rating: @selected_ratings).sort_by(&:title)   
        #else
         # @movies = Movie.where(rating: @selected_ratings).sort_by(&:release_date)
        #end
      end
    else
      sort = params[:sort]
      if sort == "title"
        @movies = Movie.where(rating: @selected_ratings).sort_by(&:title)
        @title_header = "hilite"
        session[:header] = "title"
      else
        @release_header = "hilite"
        @movies = Movie.where(rating: @selected_ratings).sort_by(&:release_date)
        session[:header] = "release"
      end
    end
    @movies
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
