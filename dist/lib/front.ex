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
        :service_running => "There aren't running services.\n",
        :request_running => "There aren't running requests or there's an active service running.\n", 
    }

    # ---------------------------------- Commands ----------------------------------
    @menu %{
        "1" => "Add a Node",
        "2" => "Show the Local Nodes",
        "3" => "Start requests",
        "4" => "Stop program",
    }

    # ---------------------------------- Main ----------------------------------

    @doc """
        Program start point
    """
    def start() do
        IO.puts(@messages[:welcome])
        Dist.start()
        menu(@menu)
    end


    # ---------------------------------- Menu ----------------------------------

    # user menus
    defp menu(menu) do
        Process.sleep(200)
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
        add_funct = IO.gets("want to add functions? [y/n]: ") |> String.replace(~r"\s+", "")
        functions = cond do
            Enum.member?(["yes", "y", "YES", "Y", "Yes"], add_funct) -> get_functions([])
            true -> []
        end
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
                IO.puts(@error[:service_running])
        end
        menu(@menu)
    end

    defp send_messages() do
        IO.puts(@messages[:fill])
    end

    defp stop_program() do
        Dist.stop()
        IO.puts(@messages[:goodbye])
    end

end