defmodule Reader.EventQueueForemanTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, eqs} = Reader.EventQueueSupervisor.start_link
    {:ok, foreman} = Reader.EventQueueForeman.start_link(supervisor: eqs)
    {:ok, eqs: eqs, foreman: foreman}
  end

  test "starts a new child worker when a topic is added", %{foreman: foreman, eqs: eqs} do
    assert Supervisor.count_children(eqs).workers == 0
    send foreman, {:topics, [], ["foo"]}
    assert Reader.EventQueueForeman.known_topics(foreman) == ["foo"]
    assert Supervisor.count_children(eqs).workers == 1
  end

  test "terminates a worker when a topic is removed", %{foreman: foreman, eqs: eqs} do
    send foreman, {:topics, [], ["foo"]}
    assert Reader.EventQueueForeman.known_topics(foreman) == ["foo"]
    assert Supervisor.count_children(eqs).workers == 1

    send foreman, {:topics, ["foo"], []}
    assert Reader.EventQueueForeman.known_topics(foreman) == []
    assert Supervisor.count_children(eqs).workers == 0
  end
end
