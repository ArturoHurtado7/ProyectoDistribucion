defmodule Chat do
    @moduledoc false

    def receive_message(message, from) do
        node_name = from |> Atom.to_string() |> String.split("@") |> Enum.at(0)
        path = "#{node_name}.txt"
        api = case File.read(path) do
            {:ok, body} -> 
                body |> String.split("\n") |> Enum.filter(fn(x) -> x != "" end) |>
                List.foldl(%{}, fn x, acc -> 
                    [key, value] = String.split(x,":")
                    key = String.to_atom(key)
                    Map.put_new(acc, key, value)
                end)
            {:error, _} -> %{}
        end
        cond do
            message == "keys" -> 
                IO.puts("write between all posible API keys: #{api[:keys]}, only one key is allowed")
                {:ok, api[:keys]}
            true -> {:ok, "done"}
                k = String.to_atom(message)
                if api[k] do
                    IO.puts("API Response: #{api[k]}")
                else
                    IO.puts("key not found")
                end
        end
    end

    def send_message(recipient, message) do
        spawn_task(__MODULE__, :receive_message, recipient, [message, Node.self()])
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