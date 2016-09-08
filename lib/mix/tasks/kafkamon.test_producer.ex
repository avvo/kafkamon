defmodule Mix.Tasks.Kafkamon.TestProducer do
  use Mix.Task


  @shortdoc "Write as many events as fast as we can to Kafka"

  def run(_args) do
    KafkaEx.start nil, nil

    schema_path = "test/data/AvvoProAdded.avsc"
    {:ok, schema_json} = File.read(schema_path)
    type = 'AvvoEvent.AvvoProAdded'
    v = %{event: %{app_id: "a", name: "n", timestamp: 0}, lawyer_id: 0}
    message = Avrolixr.Codec.encode!(v, schema_json, type)

    ProgressBar.render_spinner [
      text: "Producing to 'test'",
      spinner_color: IO.ANSI.magenta,
      interval: 100,
      frames: :braille
    ], fn ->
      produce("test", message, 50_000)
    end
  end

  def produce(_topic, _message, 0), do: nil

  def produce(topic, message, iterations_left) do
    KafkaEx.produce topic, 0, message
    produce(topic, message, iterations_left - 1)
  end
end
