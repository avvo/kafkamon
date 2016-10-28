defmodule Kafkamon.MessageController do
  use Kafkamon.Web, :controller

  alias Reader.EventQueue.{Foreman, Consumer}

  def index(conn, %{"topics" => topics, "pickedTime" => pickedTime}) do
    {:ok, datetime} = Timex.parse(pickedTime, "{ISO:Extended}")
    messages = topics
    |> String.split(",")
    |> Enum.flat_map(&Foreman.consumers_for/1)
    |> Enum.flat_map(fn consumer ->
      case Consumer.fetch_at(consumer, datetime) do
        {:ok, messages} -> messages
        _ -> []
      end
    end)

    render conn, "index.json", messages: messages
  end
end
