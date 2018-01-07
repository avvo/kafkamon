defmodule Kafkamon.Reader.EventQueue.ConsumerTest do
  use ExUnit.Case, async: true

  alias Kafkamon.Reader.EventQueue.{Broadcast,Consumer}
  alias Kafkamon.Reader.EventQueue.Consumer.{State,Message}
  alias KafkaImpl.KafkaMock

  setup do
    topic = "gandalf"

    Broadcast.subscribe(topic)
    {:ok, kafka} = KafkaMock.start_link
    {:ok, consumer} = Consumer.start_link(%State{topic_name: topic, partition_number: 0})

    schema_path = "test/data/TestEvent.avsc"
    {:ok, schema_json} = File.read(schema_path)
    type = 'TestNamespace.TestEvent'
    v = %{event: %{app_id: "a", name: "n", timestamp: 0}, lawyer_id: 0}
    v_canonical = %{
      "event" => %{"app_id" => "a", "name" => "n", "timestamp" => 0},
      "lawyer_id" => 0
    }
    message = Avrolixr.Codec.encode!(v, schema_json, type)

    {
      :ok,
      consumer: consumer,
      kafka: kafka,
      message: message,
      v_canonical: v_canonical,
      topic: topic,
    }
  end

  test "broadcasts messages it reads from kafka", %{
    topic: topic,
    message: message,
    v_canonical: v_canonical,
  } do
    KafkaMock.TestHelper.send_messages(topic, 0, [%KafkaEx.Protocol.Fetch.Message{offset: 0, value: message}])
    expected_message = %Message{topic: topic, value: v_canonical, offset: 0, partition: 0}
    assert_receive {:message, ^expected_message}
  end
end
