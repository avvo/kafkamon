defmodule Reader.TopicBroadcast do
  def subscribe() do
    :gproc.reg({:p, :l, __MODULE__})
    Reader.Topics.new_subscriber()
  end

  def notify(old_topics, new_topics) do
    :gproc.send {:p, :l, __MODULE__}, {:topics, old_topics, new_topics}
  end
  def notify(to, old_topics, new_topics) do
    send to, {:topics, old_topics, new_topics}
  end
end
