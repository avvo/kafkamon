defmodule Reader.Topics do
  use GenServer

  @refresh_time_in_ms 5 * 60 * 1000

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(state) do
    fetch_topics_later(0)
    {:ok, state}
  end

  def new_subscriber() do
    GenServer.cast(__MODULE__, {:new_subscriber, self()})
  end

  def fetch_topics() do
    GenServer.cast(__MODULE__, :fetch_topics)
  end

  def current_topics() do
    GenServer.call(__MODULE__, :current_topics)
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

  defp kafka do
    Application.fetch_env!(:kafkamon, Kafka) |> Keyword.fetch!(:impl)
  end

  defp topics() do
    kafka().metadata.topic_metadatas
    |> Enum.map(&(&1.topic))
    |> Enum.reject(&(String.starts_with?(&1, "_")))
    |> Enum.sort
  end
end
