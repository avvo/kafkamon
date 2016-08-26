defmodule Reader.Topics do
  use GenServer

  @name __MODULE__
  @refresh_time_in_ms 5 * 60 * 1000

  def start_link do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(state) do
    fetch_topics_later(0)
    {:ok, state}
  end

  def topics() do
    kafka().metadata.topic_metadatas
    |> Enum.map(&(&1.topic))
    |> Enum.reject(&(String.starts_with?(&1, "_")))
    |> Enum.sort
  end

  def fetch_topics() do
    GenServer.cast(@name, :fetch_topics)
  end

  def fetch_topics_later(delay \\ @refresh_time_in_ms) do
    Process.send_after(self(), :fetch_topics_later, delay)
  end

  def handle_cast(:fetch_topics, old_topics) do
    new_topics = topics()

    if new_topics != old_topics do
      Reader.TopicSubscribers.notify(new_topics)
    end

    {:noreply, new_topics}
  end

  def handle_info(:fetch_topics_later, state) do
    fetch_topics_later()
    handle_cast(:fetch_topics, state)
  end

  defp kafka do
    Application.fetch_env!(:kafkamon, Kafka) |> Keyword.fetch!(:impl)
  end
end
