defmodule Reader.KafkaFetch do
  require Logger

  def fetch_messages(%{topic_name: topic, partition_number: partition, offset: offset, worker_pid: pid}) do
    [response] = KafkaImpl.fetch(
      topic,
      partition,
      [
        offset: offset,
        worker_name: pid,
        auto_commit: false,
      ]
    )

    %{partitions: [%{last_offset: last_offset, message_set: messages}]} = response

    {:ok, last_offset, messages}
  end

  def decode!(value) do
    {:ok, result} = decode(value)
    result
  end

  def decode(value) do
    try do
      value |> Avrolixr.Codec.decode
    rescue
      error ->
        Logger.error "Could not decode message: #{inspect error}. Base64 encoded: #{Base.encode64(value)}"
        :error
    end
  end
end
