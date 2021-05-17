defmodule Chat do
  # Starts a DynamicSupervisor as a child of a Supervisor
  # Returns the PID of the DynamicSupervisor, which can be used to start channels and register users.
  def boot() do
    # Start a dynamic supervisor to manage channel processes.
    if Process.whereis(Chat.DynamicSupervisor) == nil do
      children = [
        {DynamicSupervisor,
         strategy: :one_for_one, name: Chat.DynamicSupervisor, restart: :permanent}
      ]

      Supervisor.start_link(children, strategy: :one_for_one, name: Chat.Root)
    else
      {:error, :already_started}
    end

    :ets.new(:messages, [:set, :public, :named_table])
  end

  # create_channel 
  def create_channel(name) do
    DynamicSupervisor.start_child(Chat.DynamicSupervisor, {Channel, name})
  end

  def register_user(username, displayname) do
    DynamicSupervisor.start_child(Chat.DynamicSupervisor, {User, {username, displayname}})
  end
end
