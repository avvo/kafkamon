defmodule Kafkamon.MessageView do
  use Kafkamon.Web, :view

  alias Kafkamon.Message

  def render("index.json", %{messages: messages}) do
    %{messages: render_many(messages, __MODULE__, "message.json")}
  end

  def render("message.json", %{message: message = %Message{}}) do
    message
  end
end
