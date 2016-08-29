defmodule Reader.EventQueueBroadcast do
  def subscribe(topic), do: topic |> key() |> :gproc.reg()

  def unsubscribe(topic), do: topic |> key() |> :gproc.unreg()

  def notify(message, topic, offset) do
    topic |> via() |> GenServer.cast({:message, topic, message, offset})
  end

  defp key(topic), do: {:p, :l, String.to_atom("event_queue_broadcast_#{topic}")}
  defp via(topic), do: {:via, :gproc, key(topic)}
end
