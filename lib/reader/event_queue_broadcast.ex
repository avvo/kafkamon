defmodule Reader.EventQueueBroadcast do
  def subscribe(topic), do: topic |> key() |> :gproc.reg()

  def unsubscribe(topic), do: topic |> key() |> :gproc.unreg()

  def notify(topic, message) do
    topic |> via() |> GenServer.cast({:message, topic, message})
  end

  defp key(topic), do: {:p, :l, {__MODULE__, topic}}
  defp via(topic), do: {:via, :gproc, key(topic)}
end
