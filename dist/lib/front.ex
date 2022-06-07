defmodule Front do
    @moduledoc """
        User interface module.

        Author: Jaime Arturo Hurtado Romero.
        Student_code: 201212121.
    """

    # ---------------------------------- Messages ----------------------------------

    @standard_messages %{
        :welcome => "\n\nWelcome to the Distribution node Agregator\n",
        :input => "\nSelect an option from the following statements:\n",
        :fill_info => "\nPlease fill the following information:\n",
        :goodbye => "\nGood bye!",
    }

    @general_commands %{
        "3" => "Add a ride service",
        "4" => "Show the ride services",
        "5" => "Remove a ride service",
        "6" => "Drop ride services",
        "7" => "Start requests",
        "8" => "Stop program",
    }

    @request_commands %{
        "1" => "Show active requests",
        "2" => "Choose a request to attend",
        "3" => "Stop requests and come back",
    }

    @error_messages %{
        :bad_input => "Bad input \n",
        :service_name => "Service name can't only be spaces.\n",
        :service_running => "There aren't running services.\n",
        :request_running => "There aren't running requests or there's an active service running.\n", 
    }

    @success_messages %{
        :service_remove => "The services have been droped.\n",
        :request_start => "The requests have been started.\n",
    }


    # ---------------------------------- Main ----------------------------------

    @doc """
        Program start point
    """
    def main() do
        IO.puts(@standard_messages[:welcome])
        Dist.start()
        menu(@general_commands)
    end


    # ---------------------------------- Menu ----------------------------------

    # user menus
    defp menu(menu) do
        Process.sleep(500)
        IO.puts(@standard_messages[:input])
        menu |> Enum.map(fn({command, description}) -> 
            IO.puts(" > #{command}. -> #{description}") 
        end)
        option = get_command()
        cond do
            menu == @general_commands and option >= 1 and option <= 8 -> 
                execute_command(option)
            menu == @request_commands and option >= 1 and option <= 3 -> 
                execute_request_commands(option)
            true -> 
                IO.puts(@error_messages[:bad_input])
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
    defp execute_command(command) do
        IO.puts("-------- #{@general_commands[Integer.to_string(command)]} --------")
        case command do
            3 -> add_service()
            4 -> show_services()
            5 -> remove_service()
            6 -> remove_services()
            7 -> start_requests()
            8 -> stop_program()
        end
    end

    # execute requests commands
    defp execute_request_commands(command) do
        IO.puts("-------- #{@request_commands[Integer.to_string(command)]} --------")
        case command do
            1 -> show_requests()
            2 -> pick_request()
            3 -> stop_request()
        end
    end

    # ---------------------------------- Services ----------------------------------

    # Add a new service
    defp add_service() do
        IO.puts(@standard_messages[:fill_info])
        name = IO.gets("Service name: ") |> String.replace(~r"\s+", "")
        channel = IO.gets("Communication channel: ") |> String.replace(~r"\s+", "")
        case name do
            "" -> 
                IO.inspect({:error, @error_messages[:service_name]})
            _ -> 
                {_status, message} = Service.add(String.to_atom(name), channel)
                IO.puts(message)
        end
        menu(@general_commands)
    end

    # print all the existing services running
    defp show_services() do
        services = Service.get_services()
        case length(services) > 0 do 
            true -> 
                Enum.map(services, fn service -> 
                    service |> IO.inspect() 
                end)
            false ->
                IO.puts(@error_messages[:service_running])
        end
        menu(@general_commands)
    end

    # remove one service
    defp remove_service() do
        IO.puts(@standard_messages[:input])
        Service.get_services() |> services_print(1, %{}) |> rm_service()
        menu(@general_commands)
    end

    # List and print services, return map of {id,sevice} tuple
    defp services_print([], _, map) do map end
    defp services_print([h|t], i, map) do 
        key = Map.keys(h) |> List.first()
        IO.puts("#{i}. -> #{key}")
        services_print(t, i+1, Map.put_new(map, i, key))
    end

    # validate if the service exist and remove
    defp rm_service(services) when services == %{} do IO.puts(@error_messages[:service_running]) end
    defp rm_service(services) do 
        input = get_command()
        cond do
            services[input] != nil -> 
                {_status, message} = services[input] |> Service.drop()
                IO.puts(message)
            true -> 
                IO.puts(@error_messages[:bad_input])
        end
    end

    # remove all services
    defp remove_services() do
        services = Service.get_services()
        cond do
            length(services) > 0 -> 
                Service.drop()
                IO.puts(@success_messages[:service_remove])
            true -> 
                IO.puts(@error_messages[:service_running])
        end
        menu(@general_commands)
    end


    # ---------------------------------- Requests ----------------------------------

    # Start requests
    defp start_requests() do
        services = Service.get_services()
        cond do
            length(services) > 0 -> 
                Request.start_requests()
                IO.puts(@success_messages[:request_start])
                menu(@request_commands)
            true -> 
                IO.puts(@error_messages[:service_running])
                menu(@general_commands)
        end
    end

    # Show requests
    defp show_requests() do
        requests = Request.get_requests()
        cond do
            requests == %{} ->
                IO.puts(@error_messages[:request_running])
            requests != %{} ->
                Enum.map(requests, fn {key, request} -> 
                    IO.puts("id => #{key}") 
                    request[:request] |> IO.inspect() 
                end) 
        end
        menu(@request_commands)
    end

    # pick one request in the list
    defp pick_request() do
        requests = Request.get_requests()
        cond do
            requests == %{} ->
                IO.puts(@error_messages[:request_running])
            requests != %{} ->
                IO.puts(@standard_messages[:input])
                requests |> IO.inspect()
                {_status, message} = get_command() |> Request.pick_request()
                IO.puts(message)
        end
        menu(@request_commands)
    end

    defp stop_request() do
        requests = Request.get_requests()
        cond do
            requests == %{} ->
                IO.puts(@error_messages[:request_running])
                menu(@request_commands)
            requests != %{} ->
                Request.stop_requests()
                menu(@general_commands)
        end
    end

    defp stop_program() do
        Service.stop_service()
        Request.stop_requests()
        IO.puts(@standard_messages[:goodbye])
    end

end