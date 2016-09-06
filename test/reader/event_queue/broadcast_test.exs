defmodule Reader.EventQueue.BroadcastTest do
  use ExUnit.Case, async: true

  alias Reader.EventQueue.Broadcast

  test "if I subscribe, I'll get messages when notified" do
    Broadcast.subscribe("foo")
    Broadcast.notify("message", "foo", 12)
    assert_received {:message, "foo", "message", 12}
  end

  test "if I unsubscribe, I'll stop receiving messages" do
    Broadcast.subscribe("foo")
    Broadcast.notify("message", "foo", 12)
    assert_received {:message, "foo", "message", 12}

    Broadcast.unsubscribe("foo")
    Broadcast.notify("new message", "foo", 13)
    refute_received {:message, "foo", "new message", 13}
  end
end
