defprotocol Kafka do
  @spec metadata(Keyword.t) :: KafkaEx.Protocol.Metadata.Response.t
  def metadata(opts \\ [])

  @spec create_worker(atom, KafkaEx.worker_init) :: Supervisor.on_start_child
  def create_worker(name, worker_init \\ [])

  @spec stream(binary, number, Keyword.t) :: GenEvent.Stream.t
  def stream(topic, partition, opts \\ [])

  @spec latest_offset(binary, integer, atom|pid) :: [KafkaEx.Protocol.Offset.Response.t] | :topic_not_found
  def latest_offset(topic, partition, name \\ KafkaEx.Server)
end
