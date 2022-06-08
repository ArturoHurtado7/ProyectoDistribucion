defmodule Front do
    @moduledoc """
        User interface module.

        Author: Jaime Arturo Hurtado Romero.
        Student_code: 201212121.
    """

    # ---------------------------------- Messages ----------------------------------

    @messages %{
        :welcome => "\n\nWelcome to the Distribution node Agregator",
        :input => "\nSelect an option:\n",
        :fill => "\nPlease fill the following information:\n",
        :goodbye => "\nGood bye!",
    }

    @error %{
        :bad_input => "Bad input \n",
        :spaces => "can't be spaces.\n",
        :no_items => "There aren't items.\n",
        :empty => "empty map or list.\n",
    }

    # ---------------------------------- Commands ----------------------------------
    @menu %{
        "1" => "Add a Node",
        "2" => "Show the Local Nodes",
        "3" => "Send a Message",
        "4" => "Stop program",
    }

    # ---------------------------------- Main ----------------------------------

    @doc """
        Program start point
    """
    def start() do
        IO.puts(@messages[:welcome])
        Dist.start()
        Chat.Application.start()
        menu(@menu)
    end


    # ---------------------------------- Menu ----------------------------------

    # user menus
    defp menu(menu) do
        Process.sleep(500)
        IO.puts(@messages[:input])
        menu |> Enum.map(fn({command, description}) -> IO.puts(" > #{command}. -> #{description}") end)
        option = get_command()
        cond do
            menu == @menu and option >= 1 and option <= map_size(@menu) -> 
                execute(option)
            true -> 
                IO.puts(@error[:bad_input])
                menu(menu)
        end
    end

    # validate and extract option number
    defp get_command() do
        input = IO.gets("\n> ") |> String.replace(~r"\s+", "")
        switch = Regex.match?(Regex.compile!("^[0-9]+$"), input)
        case switch do
            true -> 
                String.to_integer(input)
            false -> 
                input
        end
    end

    # execute input command
    defp execute(command) do
        IO.puts("-------- #{@menu[Integer.to_string(command)]} --------")
        case command do
            1 -> add_node()
            2 -> show_local_nodes()
            3 -> send_messages()
            4 -> stop_program()
        end
    end

    # ---------------------------------- Services ----------------------------------

    # Add a new service
    defp add_node() do
        IO.puts(@messages[:fill])
        cookie = IO.gets("Cookie of Node: ") |> String.replace(~r"\s+", "")
        functions = get_functions([])
        cond do
            cookie == "" -> IO.inspect({:error, @error[:spaces]})
            true -> 
                {_status, message} = Dist.add(cookie, functions)
                IO.puts(message)
        end
        menu(@menu)
    end

    defp get_functions(functions) do
        key = IO.gets("Function key: ") |> String.replace(~r"\s+", "")
        message = IO.gets("Function message: ") |> String.replace(~r"\s+", "")
        new_funct = cond do
            key == "" -> 
                IO.inspect({:error, @error[:spaces]})
                functions
            true -> 
                [{key, message} | functions]
        end
        add_funct = IO.gets("want to add another function? [y/n]: ") |> String.replace(~r"\s+", "")
        cond do
            Enum.member?(["yes", "y", "YES", "Y", "Yes"], add_funct) -> get_functions(new_funct)
            true -> new_funct
        end
    end

    # print all the existing services running
    defp show_local_nodes() do
        local_nodes = Dist.get_nodes()
        case map_size(local_nodes) > 0 do 
            true -> 
                for {k, v} <- local_nodes do
                    IO.puts("#{k} --> ")
                    IO.inspect(v)
                end
            false ->
                IO.puts(@error[:no_items])
        end
        menu(@menu)
    end

    defp send_messages() do
        IO.puts(@messages[:input])
        IO.puts("Select the local node to send the message from: ")
        Dist.get_nodes() |> Map.keys() |> nodes_print(1, %{}) |> sd_message()
        menu(@menu)
    end

    # List and print services, return map of {id,sevice} tuple
    defp nodes_print([], _, map) do map end
    defp nodes_print([key|t], i, map) do 
        IO.puts("#{i}. -> #{key}")
        nodes_print(t, i+1, Map.put_new(map, i, key))
    end

    defp sd_message(options) when options == %{} do IO.puts(@error[:empty]) end
    defp sd_message(options) do 
        input = get_command()
        IO.puts("Searching the connected nodes ...\n")
        IO.puts("this might take a while ...\n")
        cond do
            options[input] != nil -> 
                node = Dist.get_nodes() |> Map.get(options[input])
                cookie = node |> Map.get(:cookie)
                cookie |> String.to_atom() |> Node.set_cookie()
                host = node |> Map.get(:host)
                cookie |> Dist.discover()
                Process.sleep(200)
                IO.puts("Connected nodes to recieve the message: ")
                cookie |>  Dist.discover() |> 
                    Enum.filter(fn(x) -> x != host end) |> 
                    nodes_print(1, %{}) |> 
                    message_send()
            true -> 
                IO.puts(@error[:bad_input])
        end
    end

    defp message_send(receivers) do
        id = get_command()
        cond do
            receivers[id] != nil -> 
                Node.connect(receivers[id])
                Node.spawn_link(receivers[id], fn -> 
                    IO.puts("Message sent to #{receivers[id]}")
                    Chat.Application.start() 
                    Chat.send_message(receivers[id], "keys")
                end)
                new_message = get_command()
                Node.spawn_link(receivers[id], fn -> 
                    Chat.Application.start() 
                    Chat.send_message(receivers[id], new_message)
                end)
                get_command()
            true -> 
                IO.puts(@error[:bad_input])
        end
    end

    defp stop_program() do
        Dist.stop()
        IO.puts(@messages[:goodbye])
    end

end