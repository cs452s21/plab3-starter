defmodule User do
  use Agent

  def start_link({username, displayname}) do
    Agent.start_link(fn -> {username, displayname} end, name: String.to_atom(username))
  end

  def incoming(userPid, message) do
    Agent.cast(userPid, User, :print, [message])
  end

  def print({username, displayname}, message) do
    IO.puts("#{username} received #{message}")
    {username, displayname}
  end

  def getDisplayName(pid) do
    Agent.get(pid, fn {_username, displayname} -> displayname end)
  end
end
