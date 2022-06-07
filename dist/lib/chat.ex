defmodule Chat do
    @moduledoc false

    def receive_message(message, from, sender) do
        IO.puts "<#{sender}>: #{message}"
        cond do
            message != "chicken?" -> send_message(from, "chicken?")
        end
    end

    def send_message(recipient, message) do
        spawn_task(__MODULE__, :receive_message, recipient, [message, Node.self(), node()])
    end

    def spawn_task(module, fun, recipient, args) do
        recipient
        |> remote_supervisor()
        |> Task.Supervisor.async(module, fun, args)
        |> Task.await()
    end

    defp remote_supervisor(recipient) do
        {Chat.TaskSupervisor, recipient}
    end

end