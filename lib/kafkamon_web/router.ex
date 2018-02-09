defmodule KafkamonWeb.Router do
  use KafkamonWeb, :router

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

  scope "/", KafkamonWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/options/ping", OptionsController, :ping
    get "/options/fail", OptionsController, :fail
    get "/options/deploy_status", OptionsController, :deploy_status
    get "/options/full_stack_status", OptionsController, :full_stack_status
  end
end
