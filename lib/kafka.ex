defmodule Kafka do
  @impl Application.fetch_env!(:kafkamon, Kafka) |> Keyword.fetch!(:impl)

  @callback metadata(Keyword.t) :: KafkaEx.Protocol.Metadata.Response.t
  defdelegate metadata(opts \\ []), to: @impl

  @callback create_worker(atom, KafkaEx.worker_init) :: Supervisor.on_start_child
  defdelegate create_worker(name, worker_init \\ []), to: @impl

  @callback stream(binary, number, Keyword.t) :: GenEvent.Stream.t
  defdelegate stream(topic, partition, opts \\ []), to: @impl

  @callback latest_offset(binary, integer, atom|pid) :: [KafkaEx.Protocol.Offset.Response.t] | :topic_not_found
  defdelegate latest_offset(topic, partition, name \\ KafkaEx.Server), to: @impl
end
