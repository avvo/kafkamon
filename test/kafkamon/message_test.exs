defmodule Kafkamon.MessageTest do
  use ExUnit.Case, async: true

  alias Kafkamon.Message

  test "new builds `key` value" do
    message = Message.new(offset: 2, partition: 1, topic: "gandalf", value: %{})
    assert "gandalf/1#2" == message.key
  end
end
