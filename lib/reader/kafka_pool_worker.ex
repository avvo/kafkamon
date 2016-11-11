defmodule Reader.KafkaPoolWorker do
  require Logger
  use GenServer

  @poolname :kafka_workers

  def poolboy_worker_spec do
    {:ok, brokers} = KafkaImpl.Util.kafka_brokers()
    :poolboy.child_spec(@poolname, [
      {:name, {:local, @poolname}},
      {:worker_module, Reader.KafkaPoolWorker},
      {:size, Application.get_env(:kafkamon, :pool_size)},
      {:max_overflow, 0},
    ], brokers)
  end

  def start_link(brokers) do
    GenServer.start_link(__MODULE__, brokers, [])
  end

  def init(brokers) do
    create_worker(brokers)
  end

  def send_me_worker_pid_for_test do
    test_pid = self
    :poolboy.transaction(@poolname, fn pid ->
      send test_pid, {:worker_pid_for_test, pid}
    end)
  end

  def fetch(topic, partition, offset) do
    :poolboy.transaction(@poolname, fn pid ->
      GenServer.call(pid, {:fetch, topic, partition, offset})
    end)
  end

  def latest_offset(topic, partition) do
    :poolboy.transaction(@poolname, fn pid ->
      GenServer.call(pid, {:latest_offset, topic, partition})
    end)
  end

  def topics() do
    :poolboy.transaction(@poolname, fn pid ->
      GenServer.call(pid, :topics)
    end)
  end

  def handle_call({:fetch, topic, partition, offset}, _from, kafka_worker) do
    [response] = KafkaImpl.fetch(
      topic,
      partition,
      [
        offset: offset,
        worker_name: kafka_worker,
        auto_commit: false,
      ]
    )

    {:reply, {:ok, response}, kafka_worker}
  end

  def handle_call({:latest_offset, topic, partition}, _from, kafka_worker) do
    offset = case KafkaImpl.latest_offset(topic, partition, kafka_worker) |> KafkaImpl.Util.extract_offset do
      {:ok, offset} -> offset
      {:error, msg} ->
        Logger.error msg
        0
    end

    {:reply, offset, kafka_worker}
  end

  def handle_call(:topics, _from, kafka_worker) do
    topics = KafkaImpl.metadata(worker_name: kafka_worker).topic_metadatas
    |> Enum.reject(&(String.starts_with?(&1.topic, "_")))
    |> Enum.sort_by(&(&1.topic))
    |> Enum.map(fn topic_metadata ->
      {topic_metadata.topic, topic_metadata.partition_metadatas |> length}
    end)

    {:reply, topics, kafka_worker}
  end

  defp create_worker(brokers) do
    with {:ok, pid} <- KafkaImpl.create_no_name_worker(brokers, :no_consumer_group) do
      {:ok, pid}
    else
      error ->
        {:error, "Could not start kafka worker: #{inspect error}"}
    end
  end
end
