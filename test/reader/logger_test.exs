defmodule Reader.LoggerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  setup do
    {:ok, logger} = Reader.Logger.start_link topic_subscribe: false
    {:ok, logger: logger}
  end

  test "logs topics change", %{logger: logger} do
    assert Reader.Logger.known_topics(logger) == []

    capture_log(fn -> 1 end)
    assert capture_log([level: :info, format: "$message\n", colors: [enabled: false]], fn ->
      Reader.TopicBroadcast.notify(logger, [{"old", 3}, {"busted", 1}])
      Reader.TopicBroadcast.notify(logger, [{"new", 3}, {"hotness", 3}, {"busted", 1}])
      assert Reader.Logger.known_topics(logger) == [{"new", 3}, {"hotness", 3}, {"busted", 1}]
    end) == """
    Logger subscribing to old #3
    Logger subscribing to busted #1
    Topics changed. Was: [], Now: [{"old", 3}, {"busted", 1}]
    Logger subscribing to new #3
    Logger subscribing to hotness #3
    Logger unsubscribing to old #3
    Topics changed. Was: [{"old", 3}, {"busted", 1}], Now: [{"new", 3}, {"hotness", 3}, {"busted", 1}]
    """
  end
end
