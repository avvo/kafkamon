defmodule Reader.EventQueue.Supervisor do
  require Logger
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, Keyword.take(opts, [:name]))
  end

  def init(:ok) do
    [
      worker(Reader.EventQueue.Consumer, [], restart: :transient)
    ] |> supervise(strategy: :simple_one_for_one)
  end

  def start_child(name \\ __MODULE__, topic, partition_number) do
    case Supervisor.start_child(name, [topic, partition_number, [name: via(name, topic, partition_number)]]) do
      {:ok, _pid} = s -> s
      {:error, {:already_started, pid}} ->
        Logger.info("Reader.EventQueue.Supervisor already started child for #{topic}")
        {:ok, pid}
      error ->
        Logger.error("Reader.EventQueue.Supervisor error #{topic}: #{inspect error}")
        error
    end
  end

  def terminate_child(name \\ __MODULE__, topic, partition_number) do
    Supervisor.terminate_child(name, child_name(name, topic, partition_number) |> :gproc.lookup_pid)
  end

  defp child_name(name, topic, partition_number), do: {:n, :l, {name, topic, partition_number}}
  defp via(name, topic, partition_number), do: {:via, :gproc, child_name(name, topic, partition_number)}
end
