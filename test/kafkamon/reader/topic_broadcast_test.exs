defmodule Kafkamon.Reader.TopicBroadcastTest do
  use ExUnit.Case, async: true

  test "if I subscribe, I'll get messages when notified" do
    Kafkamon.Reader.TopicBroadcast.subscribe
    Kafkamon.Reader.TopicBroadcast.notify([{"b", 3}])
    assert_received {:topics, [{"b", 3}]}
  end

  test ".notify/3 can notify a specific process" do
    Kafkamon.Reader.TopicBroadcast.notify(self(), [{"b", 3}])
    assert_received {:topics, [{"b", 3}]}
  end
end
