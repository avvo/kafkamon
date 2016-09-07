defmodule Reader.TopicBroadcastTest do
  use ExUnit.Case, async: true

  test "if I subscribe, I'll get messages when notified" do
    Reader.TopicBroadcast.subscribe
    Reader.TopicBroadcast.notify(["b"])
    assert_received {:topics, ["b"]}
  end

  test ".notify/3 can notify a specific process" do
    Reader.TopicBroadcast.notify(self, ["b"])
    assert_received {:topics, ["b"]}
  end
end