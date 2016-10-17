defmodule Reader.EventQueue.Foreman do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  def init(opts \\ []) do
    if Keyword.get(opts, :topic_subscribe, true) do
      send self, :topic_subscribe
    end

    supervisor = Keyword.get(opts, :supervisor, Reader.EventQueue.Supervisor)

    {:ok, {supervisor, []}}
  end

  def known_topics(name \\ __MODULE__) do
    GenServer.call(name, :known_topics)
  end

  def handle_call(:known_topics, _from, {_s, known_topics} = state) do
    {:reply, known_topics, state}
  end

  def handle_info({:topics, new_topics}, {supervisor, known_topics}) do
    new_topics
    |> Enum.reject(&(&1 in known_topics))
    |> Enum.each(&topic_added(supervisor, &1))

    known_topics
    |> Enum.reject(&(&1 in new_topics))
    |> Enum.each(&topic_removed(supervisor, &1))

    {:noreply, {supervisor, new_topics}}
  end

  def handle_info(:topic_subscribe, state) do
    Reader.TopicBroadcast.subscribe()
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp topic_added(supervisor, {topic, partitions}) do
    for n <- 1..partitions do
      Reader.EventQueue.Supervisor.start_child(supervisor, topic, n - 1)
    end
  end

  def topic_removed(supervisor, {topic, partitions}) do
    for n <- 1..partitions do
      Reader.EventQueue.Supervisor.terminate_child(supervisor, topic, n - 1)
    end
  end
end
