defmodule Kafkamon.Message do
  @type t :: %{
    key: String.t,
    offset: integer,
    partition: integer,
    topic: String.t,
    value: map(),
  }

  defstruct [
    :key,
    :offset,
    :partition,
    :topic,
    :value,
  ]

  def new(offset: offset, partition: partition, topic: topic, value: value) do
    %__MODULE__{
      key: "#{topic}/#{partition}##{offset}",
      offset: offset,
      partition: partition,
      topic: topic,
      value: value,
    }
  end

  def stringify_keys(message = %__MODULE__{}) do
    %{
      "value"     => message.value,
      "key"       => message.key,
      "partition" => message.partition,
      "offset"    => message.offset,
      "topic"     => message.topic,
    }
  end

end
