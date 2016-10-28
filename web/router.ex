defmodule Kafkamon.Router do
  use Kafkamon.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Kafkamon do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/messages", Kafkamon do
    pipe_through :api
    get "/", MessageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Kafkamon do
  #   pipe_through :api
  # end
end
