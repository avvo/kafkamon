defmodule Kafka.Mock do
  @behaviour Kafka

  def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def set_topics(requesting_pid, new_topics) do
    update(requesting_pid, fn state ->
      state |> Map.put(:topics, new_topics)
    end)
  end

  def send_message(consumer_pid, topic, encoded_message, offset) do
    get_gen_event_pid(consumer_pid)
    |> GenEvent.notify({topic, encoded_message, offset})
  end

  ## Actual Kafka interface

  def metadata(_opts \\ []) do
    topics = get(:topics, [])

    %{
      topic_metadatas: topics |> Enum.map(& %{topic: &1})
    }
  end

  def create_worker(_name, _worker_init \\ []) do
    {:ok, :fake_pid}
  end

  def stream(topic, _partition, _opts \\ []) do
    # Because we stream from within a Task.async, we need to grab the parent Consumer pid
    self |> Process.info |> Keyword.get(:links) |> hd
    |> get_gen_event_pid()
    |> GenEvent.stream()
    |> Stream.filter_map(fn {^topic, _, _} -> true; _ -> false end,
                         fn {_, msg, offset} -> %{value: msg, offset: offset} end)
  end

  def latest_offset(_topic, _partition, _name \\ KafkaEx.Server) do
    [
      %{
        partition_offsets: [
          %{
            offset: [0]
          }
        ]
      }
    ]
  end

  defp get(key, default) do
    pid = self
    Agent.get(__MODULE__, fn state ->
      state |> Map.get(pid, %{}) |> Map.get(key, default)
    end)
  end

  defp get_and_update(pid, key, func) do
    Agent.get_and_update(__MODULE__, fn state ->
      state = state |> Map.put_new(pid, %{})

      {value, pid_map} = state |> Map.get(pid, %{}) |> Map.get_and_update(key, func)

      {value, state |> Map.put(pid, pid_map)}
    end)
  end

  defp update(pid, func) do
    Agent.update(__MODULE__, fn state ->
      state |> Map.update(pid, func.(%{}), func)
    end)
  end

  defp get_gen_event_pid(pid) do
    get_and_update pid, :messages, fn current_value ->
      gen_event = case current_value do
        nil ->
          {:ok, pid} = GenEvent.start_link
          pid
        pid when is_pid(pid) -> pid
      end

      {gen_event, gen_event}
    end
  end
end
