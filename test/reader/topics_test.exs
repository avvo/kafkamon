defmodule Reader.TopicsTest do
  use ExUnit.Case, async: false

  alias KafkaImpl.KafkaMock

  setup do
    {:ok, kafka} = KafkaMock.start_link
    {:ok, topics_pid} = Reader.Topics.start_link([])
    {:ok, topics_pid: topics_pid, kafka: kafka}
  end

  test ".new_subscriber casts the requester the topics", %{topics_pid: topics_pid} do
    KafkaMock.TestHelper.set_topics(topics_pid, [{"foo", 3}])
    Reader.Topics.fetch_topics(topics_pid)

    Reader.Topics.new_subscriber(topics_pid)
    assert_receive {:topics, [{"foo", 3}]}
  end

  test ".fetch_topics updates the state with the new topics", %{topics_pid: topics_pid} do
    KafkaMock.TestHelper.set_topics(topics_pid, [{"foo", 3}])
    Reader.Topics.fetch_topics(topics_pid)
    assert Reader.Topics.current_topics(topics_pid) == [{"foo", 3}]

    KafkaMock.TestHelper.set_topics(topics_pid, [{"foo", 3}, {"moo", 1}])
    Reader.Topics.fetch_topics(topics_pid)

    assert Reader.Topics.current_topics(topics_pid) == [{"foo", 3}, {"moo", 1}]
  end

  test ".current_topics returns the current topics in alphabetical order", %{topics_pid: topics_pid} do
    KafkaMock.TestHelper.set_topics(topics_pid, [{"foo", 3}, {"bar", 1}])
    Reader.Topics.fetch_topics(topics_pid)

    assert Reader.Topics.current_topics(topics_pid) == [{"bar", 1}, {"foo", 3}]
  end

  test "topics are broadcast when updated", %{topics_pid: topics_pid} do
    Reader.TopicBroadcast.subscribe
    KafkaMock.TestHelper.set_topics(topics_pid, [{"foo", 3}])
    Reader.Topics.fetch_topics(topics_pid)
    assert_receive {:topics, [{"foo", 3}]}

    KafkaMock.TestHelper.set_topics(topics_pid, [{"bar", 1}])
    Reader.Topics.fetch_topics(topics_pid)
    assert_receive {:topics, [{"bar", 1}]}

    KafkaMock.TestHelper.set_topics(topics_pid, [{"bar", 1}])
    Reader.Topics.fetch_topics(topics_pid)
    refute_received {:topics, [{"bar", 1}]}
  end
end
