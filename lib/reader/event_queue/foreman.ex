defmodule Reader.EventQueue.Foreman do
  use GenServer

  defmodule State do
    @type topic_name_t :: String
    @type partition_count_t :: integer
    @type topic_tuple_t :: {topic_name_t, partition_count_t}
    @type t :: %{
      supervisor: pid,
      known_topics: list(topic_tuple_t),
      topic_workers: %{optional(topic_name_t) => list(pid)}
    }
    defstruct supervisor: nil, known_topics: [], topic_workers: %{}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  def init(opts \\ []) do
    if Keyword.get(opts, :topic_subscribe, true) do
      send self, :topic_subscribe
    end

    supervisor = Keyword.get(opts, :supervisor, Reader.EventQueue.Supervisor)

    {:ok, %State{supervisor: supervisor}}
  end

  def known_topics(name \\ __MODULE__) do
    GenServer.call(name, :known_topics)
  end

  def consumers_for(name \\ __MODULE__, topic) do
    GenServer.call(name, {:consumers_for, topic})
  end

  def handle_call(:known_topics, _from, state) do
    {:reply, state.known_topics, state}
  end

  def handle_call({:consumers_for, topic}, _from, state) do
    {:reply, state.topic_workers |> Map.get(topic, []), state}
  end

  def handle_info({:topics, new_topics}, state) do
    state = new_topics
    |> Enum.reject(&(&1 in state.known_topics))
    |> Enum.reduce(state, fn {topic, partitions}, state ->
      workers = topic_added(state.supervisor, {topic, partitions})
      %{state | topic_workers: state.topic_workers |> Map.put(topic, workers)}
    end)

    state = state.known_topics
    |> Enum.reject(&(&1 in new_topics))
    |> Enum.reduce(state, fn {topic, partitions}, state ->
      topic_removed(state.supervisor, {topic, partitions})
      %{state | topic_workers: state.topic_workers |> Map.delete(topic)}
    end)

    {:noreply, %{state | known_topics: new_topics}}
  end

  def handle_info(:topic_subscribe, state) do
    Reader.TopicBroadcast.subscribe()
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp topic_added(supervisor, {topic, partitions}) do
    1..partitions
    |> Enum.map(fn n ->
      {:ok, pid} = Reader.EventQueue.Supervisor.start_child(supervisor, topic, n - 1)
      pid
    end)
  end

  def topic_removed(supervisor, {topic, partitions}) do
    for n <- 1..partitions do
      Reader.EventQueue.Supervisor.terminate_child(supervisor, topic, n - 1)
    end
  end
end
