defmodule Reader.LoggerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  setup do
    {:ok, logger} = Reader.Logger.start_link
    {:ok, logger: logger}
  end

  test "logs topics change", %{logger: logger} do
    assert Reader.Logger.known_topics(logger) == []

    capture_log(fn -> 1 end)
    assert capture_log([level: :info, format: "$message\n", colors: [enabled: false]], fn ->
      Reader.TopicBroadcast.notify(logger, ["old", "busted"])
      Reader.TopicBroadcast.notify(logger, ["new", "hotness", "busted"])
      assert Reader.Logger.known_topics(logger) == ["new", "hotness", "busted"]
    end) == """
    Logger subscribing to old
    Logger subscribing to busted
    Topics changed. Was: [], Now: ["old", "busted"]
    Logger subscribing to new
    Logger subscribing to hotness
    Logger unsubscribing to old
    Topics changed. Was: ["old", "busted"], Now: ["new", "hotness", "busted"]
    """
  end
end
