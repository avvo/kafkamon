defmodule KafkamonWeb.PageController do
  use KafkamonWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
