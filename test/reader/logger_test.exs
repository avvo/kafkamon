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
    assert capture_log([level: :info, format: "$message", colors: [enabled: false]], fn ->
      Reader.TopicBroadcast.notify(logger, ["old", "topics"], ["new", "hotness"])
      assert Reader.Logger.known_topics(logger) == ["new", "hotness"]
    end) == "Topics changed. Removed: [\"old\", \"topics\"], Added: [\"new\", \"hotness\"]"
  end
end
