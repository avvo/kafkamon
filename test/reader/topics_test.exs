defmodule Reader.TopicsTest do
  use ExUnit.Case, async: false

  setup do
    KafkaMockStore.set_topics(["foo"])
    Reader.Topics.fetch_topics
    :ok
  end

  test ".new_subscriber casts the requester the topics" do
    Reader.Topics.new_subscriber()
    assert_receive {:"$gen_cast", {:topics, [], ["foo"]}}
  end

  test ".fetch_topics updates the state with the new topics" do
    assert Reader.Topics.current_topics() == ["foo"]
    KafkaMockStore.set_topics(["foo", "moo"])
    Reader.Topics.fetch_topics
    assert Reader.Topics.current_topics() == ["foo", "moo"]
  end

  test ".current_topics returns the current topics in alphabetical order" do
    KafkaMockStore.set_topics(["foo", "bar"])
    assert Reader.Topics.current_topics() == ["bar", "foo"]
  end

end
