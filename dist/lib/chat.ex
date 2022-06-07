defmodule Chat do

  # iex.bat --sname alex@localhost -S mix
  # iex.bat --sname kate@localhost -S mix
  # Chat.Application.start()
  # Chat.send_message(:kate@localhost, "hi")

  def receive_message(message, from, sender) do
    #IO.puts message
    IO.puts "<#{sender}>: #{message}"
    if message != "chicken?" do
      send_message(from, "chicken?")
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