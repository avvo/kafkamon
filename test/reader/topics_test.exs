defmodule Reader.TopicsTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, kafka} = Kafka.Mock.start_link
    {:ok, topics_pid} = Reader.Topics.start_link([kafka_module: Kafka.Mock])
    {:ok, topics_pid: topics_pid, kafka: kafka}
  end

  test ".new_subscriber casts the requester the topics", %{topics_pid: topics_pid} do
    Kafka.Mock.set_topics(topics_pid, ["foo"])
    Reader.Topics.fetch_topics(topics_pid)

    Reader.Topics.new_subscriber(topics_pid)
    assert_receive {:topics, [], ["foo"]}
  end

  test ".fetch_topics updates the state with the new topics", %{topics_pid: topics_pid} do
    Kafka.Mock.set_topics(topics_pid, ["foo"])
    Reader.Topics.fetch_topics(topics_pid)
    assert Reader.Topics.current_topics(topics_pid) == ["foo"]

    Kafka.Mock.set_topics(topics_pid, ["foo", "moo"])
    Reader.Topics.fetch_topics(topics_pid)

    assert Reader.Topics.current_topics(topics_pid) == ["foo", "moo"]
  end

  test ".current_topics returns the current topics in alphabetical order", %{topics_pid: topics_pid} do
    Kafka.Mock.set_topics(topics_pid, ["foo", "bar"])
    Reader.Topics.fetch_topics(topics_pid)

    assert Reader.Topics.current_topics(topics_pid) == ["bar", "foo"]
  end

end
