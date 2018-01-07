defmodule Kafkamon.Reader.EventQueue do
  use GenServer

  defmodule TopicPresence do
    alias Kafkamon.Reader.EventQueue.Foreman

    def new, do: %{}

    def join(state, topic_name, {_ref, _pid} = monitor_ref_tuple) do
      case state |> Map.has_key?(topic_name) do
        false -> Foreman.start_topic(topic_name)
        _ -> nil
      end
      state |> Map.update(topic_name, [monitor_ref_tuple], fn refs ->
        [monitor_ref_tuple | refs]
      end)
    end

    def leave(state, topic_name, from_pid) do
      case state |> Map.get(topic_name, []) |> Enum.reject(fn {_ref, ^from_pid} -> true; _ -> false end) do
        [] ->
          Foreman.stop_topic(topic_name)
          state |> Map.delete(topic_name)
        new_refs -> state |> Map.put(topic_name, new_refs)
      end
    end

    def unmonitor(state, monitor_ref) do
      case state |> Enum.find(fn {_, {^monitor_ref, _from_pid}} -> true; _ -> false end) do
        {topic_name, {_ref, from_pid}} ->
          state |> leave(topic_name, from_pid)
        _ -> state
      end
    end
  end

  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, %{}, name: Keyword.get(opts, :name)
  end

  def join(pid \\ __MODULE__, topic_name) do
    GenServer.call(pid, {:join, topic_name})
  end

  def leave(pid \\ __MODULE__, topic_name) do
    GenServer.call(pid, {:leave, topic_name})
  end

  def handle_call({:join, topic_name}, {from_pid, _}, state) do
    ref = Process.monitor(from_pid)
    {:reply, :ok, state |> TopicPresence.join(topic_name, {ref, from_pid})}
  end

  def handle_call({:leave, topic_name}, {from_pid, _}, state) do
    {:reply, :ok, state |> TopicPresence.leave(topic_name, from_pid)}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {:noreply, state |> TopicPresence.unmonitor(ref)}
  end
end
