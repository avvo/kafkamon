defmodule Reader.TopicBroadcast do
  def subscribe() do
    :gproc.reg({:p, :l, __MODULE__})
    Reader.Topics.new_subscriber()
  end

  def notify(old_topics, new_topics) do
    GenServer.cast({:via, :gproc, {:p, :l, __MODULE__}},
                   {:topics, old_topics, new_topics})
  end
end
