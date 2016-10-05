defmodule Reader.EventQueue.Broadcast do
  alias Reader.EventQueue.Consumer.Message

  def subscribe(topic), do: topic |> key() |> :gproc.reg()

  def unsubscribe(topic), do: topic |> key() |> :gproc.unreg()

  def notify(message = %Message{}) do
    message.topic |> key() |> :gproc.send({:message, message})
  end

  defp key(topic), do: {:p, :l, {__MODULE__, topic}}
end
