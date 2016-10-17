defmodule Reader.EventQueue.Supervisor do
  require Logger
  use Supervisor

  alias Reader.EventQueue.Consumer.State

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, Keyword.take(opts, [:name]))
  end

  def init(:ok) do
    [
      worker(Reader.EventQueue.Consumer, [], restart: :transient)
    ] |> supervise(strategy: :simple_one_for_one)
  end

  def start_child(name \\ __MODULE__, topic, partition_number) do
    with {:ok, brokers} <- KafkaImpl.Util.kafka_brokers(),
         {:ok, pid} <- Supervisor.start_child(name, [
           %State{topic_name: topic, partition_number: partition_number, brokers: brokers},
           [name: via(name, topic, partition_number)]
         ]) do
      {:ok, pid}
    else
      {:error, {:already_started, pid}} ->
        Logger.info("Reader.EventQueue.Supervisor already started child for #{topic}")
        {:ok, pid}
      error ->
        Logger.error("Reader.EventQueue.Supervisor error #{topic}: #{inspect error}")
        :timer.sleep(5)
        System.halt(1)
        error
    end
  end

  def terminate_child(name \\ __MODULE__, topic, partition_number) do
    Supervisor.terminate_child(name, child_name(name, topic, partition_number) |> :gproc.lookup_pid)
  rescue
    ArgumentError -> Logger.warn "Child already terminated for #{topic} #{partition_number}"
  end

  defp child_name(name, topic, partition_number), do: {:n, :l, {name, topic, partition_number}}
  defp via(name, topic, partition_number), do: {:via, :gproc, child_name(name, topic, partition_number)}

end
