defmodule Kafkamon.Reader.EventQueue.Foreman do
  require Logger

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  def init(opts \\ []) do
    if Keyword.get(opts, :topic_subscribe, true) do
      send self(), :topic_subscribe
    end

    supervisor = Keyword.get(opts, :supervisor, Kafkamon.Reader.EventQueue.Supervisor)

    {:ok, {supervisor, []}}
  end

  def known_topics(name \\ __MODULE__) do
    GenServer.call(name, :known_topics)
  end

  def start_topic(name \\ __MODULE__, topic_name) do
    GenServer.call(name, {:start_topic, topic_name})
  end

  def stop_topic(name \\ __MODULE__, topic_name) do
    GenServer.call(name, {:stop_topic, topic_name})
  end

  def handle_call({:start_topic, topic_name}, _from, {supervisor, known_topics} = state) do
    case known_topics |> Enum.find(fn {^topic_name, _} -> true; _ -> false end) do
      {_,_} = topic_info -> topic_added(supervisor, topic_info)
      _ -> nil
    end
    {:reply, :ok, state}
  end

  def handle_call({:stop_topic, topic_name}, _from, {supervisor, known_topics} = state) do
    case known_topics |> Enum.find(fn {^topic_name, _} -> true; _ -> false end) do
      {_,_} = topic_info -> topic_removed(supervisor, topic_info)
      _ -> nil
    end
    {:reply, :ok, state}
  end

  def handle_call(:known_topics, _from, {_s, known_topics} = state) do
    {:reply, known_topics, state}
  end

  def handle_info({:topics, new_topics}, {supervisor, known_topics}) do
    known_topics
    |> Enum.reject(&(&1 in new_topics))
    |> Enum.each(&topic_removed(supervisor, &1))

    {:noreply, {supervisor, new_topics}}
  end

  def handle_info(:topic_subscribe, state) do
    Kafkamon.Reader.TopicBroadcast.subscribe()
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp topic_added(supervisor, {topic, partitions}) do
    Logger.debug("Starting workers for #{topic} with #{partitions} partitions")
    for n <- 1..partitions do
      Kafkamon.Reader.EventQueue.Supervisor.start_child(supervisor, topic, n - 1)
    end
  end

  def topic_removed(supervisor, {topic, partitions}) do
    Logger.debug("Stopping workers for #{topic} with #{partitions} partitions")
    for n <- 1..partitions do
      Kafkamon.Reader.EventQueue.Supervisor.terminate_child(supervisor, topic, n - 1)
    end
  end
end
