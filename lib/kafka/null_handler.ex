defmodule Kafka.NullHandler do
  use GenEvent

  def handle_event(_, _), do: {:ok, []}

  def handle_call(:messages, _), do: {:ok, [], []}
end
