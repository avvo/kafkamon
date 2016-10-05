defmodule Reader.Logger do
  require Logger

  alias Reader.EventQueue.Consumer.Message

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

  def handle_info({:topics, new_topics}, known_topics) do
    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(fn {topic, n} ->
      Logger.info "Logger subscribing to #{topic} ##{n}"
      Reader.EventQueue.Broadcast.subscribe(topic)
    end)

    known_topics |> Enum.reject(&(&1 in new_topics)) |> Enum.each(fn {topic, n} ->
      Logger.info "Logger unsubscribing to #{topic} ##{n}"
      Reader.EventQueue.Broadcast.unsubscribe(topic)
    end)

    Logger.info "Topics changed. Was: #{inspect known_topics}, Now: #{inspect new_topics}"

    {:noreply, new_topics}
  end

  def handle_info({:message, topic, {:error, error}, offset}, state) do
    Logger.error "[#{topic}##{offset}] Error parsing message, got #{inspect error}"
    {:noreply, state}
  end

  def handle_info({:message, message = %Message{}}, state) do
    Logger.info "[#{message.topic}/#{message.partition}##{message.offset}] #{inspect message.value}"
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
