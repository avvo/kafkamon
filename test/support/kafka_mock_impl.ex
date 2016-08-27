defimpl Kafka, for: MockImpl do
  def metadata(opts \\ []), do: []
  def create_worker(name, worker_init \\ []), do: []
  def stream(topic, partition, opts \\ []), do: []
  def latest_offset(topic, partition, name \\ KafkaEx.Server), do: []
end
