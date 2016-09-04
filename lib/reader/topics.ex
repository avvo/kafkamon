defmodule Reader.Topics do
  use GenServer

  @refresh_time_in_ms 5 * 60 * 1000

  def start_link(opts \\ []) do
    auto_fetch = Keyword.get(opts, :auto_fetch, false)
    GenServer.start_link(__MODULE__, auto_fetch, Keyword.take(opts, [:name]))
  end

  def init(auto_fetch) do
    if auto_fetch do
      fetch_topics_later(0)
    end
    {:ok, []}
  end

  def new_subscriber(name \\ __MODULE__) do
    GenServer.cast(name, {:new_subscriber, self()})
  end

  def fetch_topics(name \\ __MODULE__) do
    GenServer.cast(name, :fetch_topics)
  end

  def current_topics(name \\ __MODULE__) do
    GenServer.call(name, :current_topics)
  end

  def handle_call(:current_topics, _from, topics) do
    {:reply, topics, topics}
  end

  def handle_cast({:new_subscriber, from}, topics) do
    GenServer.cast(from, {:topics, [], topics})
    {:noreply, topics}
  end

  def handle_cast(:fetch_topics, old_topics) do
    new_topics = topics()

    if new_topics != old_topics do
      new = new_topics |> Enum.reject(&(&1 in old_topics))
      old = old_topics |> Enum.reject(&(&1 in new_topics))

      Reader.TopicBroadcast.notify(old, new)
    end

    {:noreply, new_topics}
  end

  def handle_info(:fetch_topics_later, state) do
    fetch_topics_later()
    handle_cast(:fetch_topics, state)
  end

  defp fetch_topics_later(delay \\ @refresh_time_in_ms) do
    Process.send_after(self(), :fetch_topics_later, delay)
  end

  defp topics() do
    Kafka.metadata.topic_metadatas
    |> Enum.map(&(&1.topic))
    |> Enum.reject(&(String.starts_with?(&1, "_")))
    |> Enum.sort
  end
end
