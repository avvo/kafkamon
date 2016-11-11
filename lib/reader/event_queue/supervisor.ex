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
    with {:ok, pid} <- do_start_child(name, topic, partition_number) do
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
    Supervisor.terminate_child(name, child_name(topic, partition_number) |> Process.whereis)
  end

  defp child_name(topic, partition_number) do
    [__MODULE__, topic, partition_number] |> Enum.join("_") |> String.to_atom
  end

  defp do_start_child(name, topic, partition_number) do
    child_name = child_name(topic, partition_number)
    case child_name |> Process.whereis do
      nil -> Supervisor.start_child(name, [
               %State{topic_name: topic, partition_number: partition_number},
               [name: child_name]
             ])
      pid when is_pid(pid) -> {:ok, pid}
    end
  end

end
