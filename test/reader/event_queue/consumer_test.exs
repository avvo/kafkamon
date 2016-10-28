defmodule Reader.EventQueue.ConsumerTest do
  use ExUnit.Case, async: true

  alias Reader.EventQueue.{Broadcast,Consumer}
  alias Reader.EventQueue.Consumer.{State}
  alias KafkaImpl.KafkaMock
  alias Kafkamon.Message

  setup do
    topic = "gandalf"

    Broadcast.subscribe(topic)
    {:ok, kafka} = KafkaMock.start_link
    {:ok, consumer} = Consumer.start_link(%State{topic_name: topic, partition_number: 0})

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
    KafkaMock.send_message(consumer, {topic, 0, %KafkaEx.Protocol.Fetch.Message{offset: 0, value: message}, 0})
    expected_message = Message.new(
      offset: 0,
      partition: 0,
      topic: topic,
      value: v_canonical,
    )
    assert_receive {:message, ^expected_message}
  end

  test "fetch results at a specific datetime", %{
    consumer: consumer,
    topic: topic,
    message: message,
    v_canonical: v_canonical
  } do
    {:ok, datetime} = DateTime.from_unix(1464096368) # 2016-05-24 06:26:08 -0700

    KafkaMock.set_offset_at(consumer, datetime, 3)

    msg1 = Message.new(offset: 1, partition: 0, topic: topic, value: v_canonical)
    msg2 = Message.new(offset: 2, partition: 0, topic: topic, value: v_canonical)
    msg3 = Message.new(offset: 3, partition: 0, topic: topic, value: v_canonical)
    msg4 = Message.new(offset: 4, partition: 0, topic: topic, value: v_canonical)

    KafkaMock.send_messages(consumer,
      [msg1, msg2, msg3, msg4] |> Enum.map(&msg_to_tuple(&1, message)))

    expected_messages = [msg3, msg4]

    assert {:ok, ^expected_messages} = Consumer.fetch_at(consumer, datetime)
  end

  defp msg_to_tuple(msg = %{}, message) do
    {msg.topic,
      msg.partition,
      %KafkaEx.Protocol.Fetch.Message{offset: msg.offset, value: message},
      msg.offset}
  end
end
