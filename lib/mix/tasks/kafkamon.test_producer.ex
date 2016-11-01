defmodule Mix.Tasks.Kafkamon.TestProducer do
  use Mix.Task

  @event_type 'AvvoEvent.AvvoProAdded'

  @shortdoc "Write as many events as fast as we can to Kafka"

  def run(_args) do
    {:ok, brokers} = KafkaImpl.Util.kafka_brokers()
    {:ok, worker} = KafkaImpl.create_no_name_worker(brokers, :no_consumer_group)

    schema_path = "test/data/AvvoProAdded.avsc"
    {:ok, schema_json} = File.read(schema_path)

    ProgressBar.render_spinner [
      text: "Producing to 'test'",
      spinner_color: IO.ANSI.magenta,
      interval: 100,
      frames: :braille
    ], fn ->
      produce("test2", 50, worker, schema_json)
    end
  end

  def produce(_topic, 0, _worker, _), do: nil


  def produce(topic, iterations_left, worker, schema_json) do
    ts = DateTime.utc_now |> DateTime.to_unix()
    v = %{event: %{app_id: "a", name: "n", timestamp: ts}, lawyer_id: 100000 + iterations_left}
    message = Avrolixr.Codec.encode!(v, schema_json, @event_type)
    KafkaEx.produce topic, 0, message, worker_name: worker
    :timer.sleep 100
    produce(topic, message, iterations_left - 1, worker)
  end
end
