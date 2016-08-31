defmodule KafkaMockStore do
  def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def topics do
    Agent.get(__MODULE__, fn state ->
      state |> Map.get(:topics, [])
    end)
  end

  def set_topics(new_topics) do
    Agent.update(__MODULE__, fn state ->
      state |> Map.put(:topics, new_topics)
    end)
  end

end

defimpl Kafka, for: Mock do
  def start_link do
    KafkaMockStore.start_link
  end

  def metadata(_opts \\ []) do
    start_link()
    %{
      topic_metadatas: KafkaMockStore.topics
        |> Enum.map(&(%{topic: &1}))
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

end
