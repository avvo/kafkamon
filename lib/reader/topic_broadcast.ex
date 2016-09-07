defmodule Reader.TopicBroadcast do
  def subscribe() do
    :gproc.reg({:p, :l, __MODULE__})
    Reader.Topics.new_subscriber()
  end

  def notify(new_topics) do
    :gproc.send {:p, :l, __MODULE__}, {:topics, new_topics}
  end
  def notify(to, new_topics) do
    send to, {:topics, new_topics}
  end
end
