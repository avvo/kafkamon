defmodule Kafkamon.MessageViewTest do
  use Kafkamon.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders index.json" do
    assert render(Kafkamon.MessageView, "index.json", %{messages: []}) ==
           %{messages: []}

    message = Kafkamon.Message.new(offset: 1, partition: 2, topic: "foo", value: %{bar: 1})
    assert render(Kafkamon.MessageView, "index.json", %{messages: [message]}) ==
           %{messages: [message]}
  end
end
