defmodule Reader.OffsetSearch do
  def offset_at(erltime, %{topic_name: topic, partition_number: partition, worker_pid: worker}) do
    case KafkaImpl.offset(topic, partition, erltime, worker) |> KafkaImpl.Util.extract_offset do
      :no_offset ->
        search(erltime, topic, partition, worker)
      {:ok, offset} -> {:ok, offset}
      x -> x # {:error, message}
    end
  end

  def search(erltime, topic, partition, worker) do
    {:ok, search_time} = NaiveDateTime.from_erl(erltime)
    {:ok, earliest_offset} = KafkaImpl.earliest_offset(topic, partition, worker) |> KafkaImpl.Util.extract_offset
    {:ok, latest_offset} = KafkaImpl.earliest_offset(topic, partition, worker) |> KafkaImpl.Util.extract_offset
    config = %{
      topic_name: topic,
      partition_number: partition,
      worker_pid: worker,
      search_time: search_time,
      latest_offset: latest_offset,
      offset: earliest_offset
    }

    fetch_at(config)
  end

  def fetch_at(config) do
    IO.inspect config
    {:ok, last_offset_fetched, messages} = Reader.KafkaFetch.fetch_messages(config)

    case message_search(config.search_time, messages) do
      {:ok, offset} -> {:ok, offset}
      :no_messages ->
        cond do
          last_offset_fetched >= config.latest_offset -> :not_found
          true -> fetch_at(%{config | offset: last_offset_fetched+1})
        end
    end
  end

  def message_search(_search_time, []), do: :no_messages
  def message_search(search_time, [message | tail]) do
    message_time = message.value
    |> Reader.KafkaFetch.decode!
    |> Map.fetch!("event")
    |> Map.fetch!("timestamp")
    |> DateTime.from_unix!
    |> DateTime.to_naive

    cond do
      message_time > search_time -> {:ok, message.offset}
      true -> message_search(search_time, tail)
    end
  end
end
