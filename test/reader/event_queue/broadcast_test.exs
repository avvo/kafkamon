defmodule Reader.EventQueue.BroadcastTest do
  use ExUnit.Case, async: true

  alias Reader.EventQueue.Broadcast
  alias Reader.EventQueue.Consumer.Message

  @message %Message{value: "message", topic: "foo", offset: 12, partition: 3}

  test "if I unsubscribe, I'll stop receiving messages" do
    Broadcast.subscribe("foo")
    Broadcast.notify(@message)
    assert_received {:message, @message}

    Broadcast.unsubscribe("foo")
    new_message = %{@message | offset: 13}
    Broadcast.notify(new_message)
    refute_received {:message, ^new_message}
  end
end
