defmodule Kafka.Mock do
  @behaviour Kafka

  def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def set_topics(requesting_pid, new_topics) do
    update(requesting_pid, fn state ->
      state |> Map.put(:topics, new_topics)
    end)
  end

  def metadata(_opts \\ []) do
    topics = get(:topics, [])

    %{
      topic_metadatas: topics |> Enum.map(& %{topic: &1})
    }
  end

  def create_worker(_name, _worker_init \\ []) do
    {:ok, :fake_pid}
  end

  def stream(_topic, _partition, _opts \\ []) do
    []
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

  defp update(pid, func) do
    Agent.update(__MODULE__, fn state ->
      state |> Map.update(pid, func.(%{}), func)
    end)
  end
end
