defmodule Reader.EventQueueForeman do
  use GenServer

  def start_link(opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, Reader.EventQueueSupervisor)
    GenServer.start_link(__MODULE__, supervisor, Keyword.take(opts, [:name]))
  end

  def init(supervisor) do
    send self, :topic_subscribe
    {:ok, {supervisor, []}}
  end

  def known_topics(name \\ __MODULE__) do
    GenServer.call(name, :known_topics)
  end

  def handle_call(:known_topics, _from, {_s, known_topics} = state) do
    {:reply, known_topics, state}
  end

  def handle_info({:topics, old_topics, new_topics}, {supervisor, known_topics}) do
    all_topics = ((known_topics |> Enum.reject(&(&1 in old_topics))) ++ new_topics) |> Enum.uniq

    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(&topic_added(supervisor, &1))

    old_topics |> Enum.filter(&(&1 in known_topics)) |> Enum.each(&topic_removed(supervisor, &1))

    {:noreply, {supervisor, all_topics}}
  end

  def handle_info(:topic_subscribe, state) do
    Reader.TopicBroadcast.subscribe()
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp topic_added(supervisor, topic) do
    Reader.EventQueueSupervisor.start_child(supervisor, topic)
  end

  def topic_removed(supervisor, topic) do
    Reader.EventQueueSupervisor.terminate_child(supervisor, topic)
  end
end
