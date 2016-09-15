defmodule Reader.TopicBroadcastTest do
  use ExUnit.Case, async: true

  test "if I subscribe, I'll get messages when notified" do
    Reader.TopicBroadcast.subscribe
    Reader.TopicBroadcast.notify([{"b", 3}])
    assert_received {:topics, [{"b", 3}]}
  end

  test ".notify/3 can notify a specific process" do
    Reader.TopicBroadcast.notify(self, [{"b", 3}])
    assert_received {:topics, [{"b", 3}]}
  end
end
