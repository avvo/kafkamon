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

  def start_child(name \\ __MODULE__, topic) do
    :ok = case Supervisor.start_child(name, [topic, [name: via(topic)]]) do
      {:ok, _pid} ->
        :ok
      {:error, {:already_started, _pid}} ->
        Logger.info("Reader.EventQueue.Supervisor already started child for #{topic}")
        :ok
      error ->
        Logger.error("Reader.EventQueue.Supervisor error #{topic}: #{inspect error}")
        :error
    end
  end

  def terminate_child(name \\ __MODULE__, topic) do
    Supervisor.terminate_child(name, topic |> child_name() |> :gproc.lookup_pid)
  end

  defp child_name(topic), do: {:n, :l, {:topic_reader, topic}}
  defp via(topic), do: {:via, :gproc, child_name(topic)}
end
