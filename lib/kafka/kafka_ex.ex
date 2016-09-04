defmodule Kafka.KafkaEx do
  @behaviour Kafka
  defdelegate metadata(opts \\ []), to: KafkaEx
  defdelegate create_worker(name, worker_init \\ []), to: KafkaEx
  defdelegate stream(topic, partition, opts \\ []), to: KafkaEx
  defdelegate latest_offset(topic, partition, name \\ KafkaEx.Server), to: KafkaEx
end
