defmodule Chat.Application do
    @moduledoc """
        Chat Application module.

        Author: Jaime Arturo Hurtado Romero.
        Student_code: 201212121.
    """

  use Application

  def start() do
    children = [{Task.Supervisor, name: Chat.TaskSupervisor}]
    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
