defimpl Kafka, for: Mock do
  def metadata(_opts \\ []) do
    %{
      topic_metadatas: [
        %{topic: "foo"}
      ]
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
