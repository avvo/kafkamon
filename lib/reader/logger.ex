defmodule Reader.Logger do
  require Logger

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.take(opts, [:name]))
  end

  def init(:ok) do
    Reader.TopicBroadcast.subscribe()
    {:ok, []}
  end

  def known_topics(name \\ __MODULE__) do
    GenServer.call(name, :known_topics)
  end

  def handle_call(:known_topics, _from, known_topics) do
    {:reply, known_topics, known_topics}
  end

  def handle_info({:topics, old, new}, known_topics) do
    all_topics = ((known_topics |> Enum.reject(&(&1 in old))) ++ new) |> Enum.uniq

    new |> Enum.reject(&(&1 in known_topics)) |> Enum.each(fn topic ->
      Reader.EventQueue.Broadcast.subscribe(topic)
    end)

    old |> Enum.filter(&(&1 in known_topics)) |> Enum.each(fn topic ->
      Reader.EventQueue.Broadcast.unsubscribe(topic)
    end)

    Logger.info "Topics changed. Removed: #{inspect old}, Added: #{inspect new}"

    {:noreply, all_topics}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  def handle_cast({:message, topic, {:error, error}, offset}, state) do
    Logger.error "[#{topic}##{offset}] Error parsing message, got #{inspect error}"
    {:noreply, state}
  end

  def handle_cast({:message, topic, message, offset}, state) do
    Logger.info "[#{topic}##{offset}] #{inspect message}"
    {:noreply, state}
  end

end
