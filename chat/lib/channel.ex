defmodule Channel do
  use Agent

  def start_link(channel) do
    Agent.start_link(fn -> restore(channel) end, name: globalName(channel))
  end

  def globalName(channel) do
    {:global, channel}
  end

  def restore(channel) do
    case :ets.lookup(:messages, channel) do
      [] -> {[], []}
      [{_channel, messages}] -> {messages, []}
    end
  end

  def sendMessage(channel, message) do
    updateState(channel, message)
    notify(channel, message)
  end

  def updateState(channel, message) do
    Agent.update(globalName(channel), fn {msgs, users} -> {[message | msgs], users} end)
    Agent.get(globalName(channel), fn {msgs, _users} -> :ets.insert(:messages, {channel, msgs}) end)
  end

  def notify(channel, message) do
    Agent.get(globalName(channel), fn {_msgs, users} -> pushMessage(message, users) end)
  end

  def pushMessage(message, users) do
    Enum.each(users, fn u -> User.incoming(u, message) end)
  end

  def sendMessage(channel, fromUser, message) do
    fromUserDisplayName = User.getDisplayName(fromUser)
    msgWithUser = fromUserDisplayName <> ": " <> message

    updateState(channel, msgWithUser)
    notify(channel, msgWithUser)
  end

  def stats(channel) do
    Agent.get(globalName(channel), fn {msgs, users} -> IO.puts(length(msgs) / length(users)) end)
  end

  def messages(channel) do
    Agent.get(globalName(channel), fn {msgs, _users} -> msgs end)
  end

  def users(channel) do
    Agent.get(globalName(channel), fn {_msgs, users} -> users end)
  end

  def join(channel, user) do
    Agent.update(globalName(channel), fn {msgs, users} -> {msgs, [user | users]} end)
  end
end
