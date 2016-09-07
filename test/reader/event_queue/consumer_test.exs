defmodule Reader.EventQueue.ConsumerTest do
  use ExUnit.Case, async: true

  alias Reader.EventQueue.{Broadcast,Consumer}

  setup do
    topic = "gandalf"

    {:ok, kafka} = Kafka.Mock.start_link
    {:ok, consumer} = Consumer.start_link(topic, [])

    schema_path = "test/data/AvvoProAdded.avsc"
    {:ok, schema_json} = File.read(schema_path)
    type = 'AvvoEvent.AvvoProAdded'
    v = %{event: %{app_id: "a", name: "n", timestamp: 0}, lawyer_id: 0}
    v_canonical = %{
      "event" => %{"app_id" => "a", "name" => "n", "timestamp" => 0},
      "lawyer_id" => 0
    }
    message = Avrolixr.Codec.encode!(v, schema_json, type)

    {:ok,
      consumer: consumer,
      kafka: kafka,
      message: message,
      v_canonical: v_canonical,
      topic: topic,
    }
  end

  test "broadcasts messages it reads from kafka", %{
    consumer: consumer,
    topic: topic,
    message: message,
    v_canonical: v_canonical
  } do
    Broadcast.subscribe(topic)
    Kafka.Mock.send_message(consumer, topic, message, 0)
    assert_receive {:message, ^topic, ^v_canonical, 0}
  end
end
