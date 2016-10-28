defmodule Reader.EventQueue.ForemanTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  alias Reader.EventQueue.Foreman
  alias KafkaImpl.KafkaMock

  setup do
    {:ok, _kafka_mock} = KafkaMock.start_link
    {:ok, eqs} = Reader.EventQueue.Supervisor.start_link
    {:ok, foreman} = Foreman.start_link(supervisor: eqs, topic_subscribe: false)
    {:ok, eqs: eqs, foreman: foreman}
  end

  test "starts a new child worker when a topic is added", %{foreman: foreman, eqs: eqs} do
    capture_log(fn -> 1 end) # clear the log
    assert Supervisor.count_children(eqs).workers == 0
    assert capture_log([level: :info, format: "$message", colors: [enabled: false]], fn ->
      send foreman, {:topics, [{"foo1", 3}]}
      assert Foreman.known_topics(foreman) == [{"foo1", 3}]
    end) == "" # no logs, like already started
    assert Supervisor.count_children(eqs).workers == 3
  end

  test "terminates a worker when a topic is removed", %{foreman: foreman, eqs: eqs} do
    send foreman, {:topics, [{"foo2", 3}]}
    assert Foreman.known_topics(foreman) == [{"foo2", 3}]
    assert Supervisor.count_children(eqs).workers == 3

    send foreman, {:topics, []}
    assert Foreman.known_topics(foreman) == []
    assert Supervisor.count_children(eqs).workers == 0
  end

  test "doesn't blow up when creating an already existing worker", %{foreman: foreman, eqs: eqs} do
    send foreman, {:topics, [{"foo3", 3}]}
    assert Foreman.known_topics(foreman) == [{"foo3", 3}]

    {:ok, foreman2} = Foreman.start_link(supervisor: eqs, topic_subscribe: false)
    send foreman2, {:topics, [{"foo3", 3}]}
    assert Foreman.known_topics(foreman2) == [{"foo3", 3}]

    assert Supervisor.count_children(eqs).workers == 3
  end
end
