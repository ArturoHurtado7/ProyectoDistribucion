defmodule Chat.Application do
  @moduledoc false

  use Application

  def start() do
    children = [
      {Task.Supervisor, name: Chat.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end