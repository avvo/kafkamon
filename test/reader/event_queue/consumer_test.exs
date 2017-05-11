defmodule Reader.EventQueue.ConsumerTest do
  use ExUnit.Case, async: true

  alias Reader.EventQueue.{Broadcast,Consumer}
  alias Reader.EventQueue.Consumer.{State,Message}
  alias KafkaImpl.KafkaMock

  setup do
    topic = "gandalf"

    Broadcast.subscribe(topic)
    {:ok, kafka} = KafkaMock.start_link
    {:ok, consumer} = Consumer.start_link(%State{topic_name: topic, partition_number: 0})

    Reader.KafkaPoolWorker.send_me_worker_pid_for_test
    worker_pid = receive do
      {:worker_pid_for_test, pid} -> pid
    end

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
      worker_pid: worker_pid,
    }
  end

  test "broadcasts messages it reads from kafka", %{
    topic: topic,
    message: message,
    v_canonical: v_canonical,
    worker_pid: worker_pid,
  } do
    KafkaMock.TestHelper.send_message(worker_pid, {topic, 0, %KafkaEx.Protocol.Fetch.Message{offset: 0, value: message}, 0})
    expected_message = %Message{topic: topic, value: v_canonical, offset: 0, partition: 0}
    assert_receive {:message, ^expected_message}
  end
end
