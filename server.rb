# Allison Browne and Patrick Kennedy
# Movie-catalog-deluxe challenge
# 11/25/14

require 'pg'
require 'sinatra'
require 'pry'
require 'sinatra/reloader'

def db_connection
  begin

    connection = PG.connect(dbname: 'movies')

    yield(connection)
    # allows this method to accept a block
    # of code (in the form of a do..end or {..} block) that can be run in the middle of the method.

  ensure
    connection.close
  end
end

get '/actors' do

  db_connection do |conn|
    @actors_and_id = conn.exec_params('SELECT actors.name, actors.id  FROM actors ORDER BY actors.name')
  end
  # will show a list of actors, sorted alphabetically by name. Each actor name is a link to the details page for that actor.
  erb :'actors/index'

end

get '/actors/:id' do
  # will show the details for a given actor.
  # This page should contain a list of movies that the actor has starred in
  # and what their role was. Each movie should link to the details page for that movie.
  @id = params[:id]

  db_connection do |conn|
    @actor_movies_and_roles = conn.exec_params("SELECT movies.title, cast_members.character, movies.id, actors.name FROM movies
    JOIN cast_members ON cast_members.movie_id = movies.id
    JOIN actors ON actors.id = cast_members.actor_id
    WHERE actors.id = #{@id}")

    end
  erb :'actors/show'
end

get '/movies' do

  db_connection do |conn|
    @movies_and_id = conn.exec_params('SELECT movies.id AS id, movies.title AS title, movies.year AS year, studios.name AS studio, genres.name AS genre
      FROM movies JOIN genres ON movies.genre_id = genres.id
      JOIN studios ON movies.studio_id = studios.id
      ORDER BY movies.title')
  end
  # will show a table of movies, sorted alphabetically by title.
  # The table includes the movie title,
  # the year it was released, the rating, the genre, and the studio that produced it.
  # Each movie title is a link to the details page for that movie.
  erb :'movies/index'
end

get '/movies/:id' do
  @id = params[:id]
  db_connection do |conn|
    @movie_info = conn.exec_params("SELECT movies.title AS title, genres.name AS genre_name,
    genres.id AS genre_id, studios.name AS studio_name,
    studios.id AS studio_id, actors.name AS actors_name,
    cast_members.character, actors.id AS actors_id FROM movies
    JOIN cast_members ON cast_members.movie_id = movies.id
    JOIN actors ON actors.id = cast_members.actor_id
    JOIN genres ON genres.id = movies.genre_id
    JOIN studios ON studios.id = movies.studio_id
    WHERE movies.id = #{@id}")
    # binding.pry
    # Visiting `/movies/:id` will show the details for the movie.
    # This page should contain information about the movie (including genre and studio)
    # as well as a list of all of the actors and their roles. Each actor name is a link to the details page for that actor.
  end

erb :'movies/show'
end
