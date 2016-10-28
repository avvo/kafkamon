defmodule Kafkamon.MessageController do
  use Kafkamon.Web, :controller

  def index(conn, %{topics: topics, pickedTime: pickedTime}) do
    messages = []
    render conn, "index.json", messages: messages
  end
end
