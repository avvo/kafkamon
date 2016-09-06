defmodule Reader.EventQueue.Broadcast do
  def subscribe(topic), do: topic |> key() |> :gproc.reg()

  def unsubscribe(topic), do: topic |> key() |> :gproc.unreg()

  def notify(message, topic, offset) do
    topic |> key() |> :gproc.send({:message, topic, message, offset})
  end

  defp key(topic), do: {:p, :l, {__MODULE__, topic}}
end
