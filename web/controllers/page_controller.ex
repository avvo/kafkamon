defmodule Kafkamon.PageController do
  use Kafkamon.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
