defmodule Reader.TopicBroadcastTest do
  use ExUnit.Case, async: false

  test "if I subscribe, I'll get messages when notified" do
    Reader.TopicBroadcast.subscribe
    Reader.TopicBroadcast.notify(["a"], ["b"])
    assert_received {:topics, ["a"], ["b"]}
  end

  test ".notify/3 can notify a specific process" do
    Reader.TopicBroadcast.notify(self, ["a"], ["b"])
    assert_received {:topics, ["a"], ["b"]}
  end
end
