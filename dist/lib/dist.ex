defmodule Dist do

  # ---------------------------------- Agents ID ----------------------------------
  @nodes :nodes_up
  @domain :domain_node
  @connected :connected_nodes

  @host "machine"
  @domain_name "local"
  @limit 255

  def start do
    # ---------------------------------- Agents ----------------------------------
    # start_agents
    Agent.start_link(fn -> %{} end, name: @nodes)
    Agent.start_link(fn -> [] end, name: @connected)
    Agent.start_link(fn -> new_domain_name(@host, @domain_name, 0, false) end, name: @domain)

    # ---------------------------------- Nodes ----------------------------------
    # get the ip address of the machine
    ip_device = :inet.getiflist() |> elem(1) |> Enum.at(1) 
      |> List.to_string() |> String.split(".") 
      |> Enum.map(&String.to_integer/1)|> List.to_tuple()

    # ---------------------------------- Server ----------------------------------
    # Start the distributed LAN server
    Mdns.Server.start()
    Mdns.Server.set_ip(ip_device)
    Mdns.Server.add_service(%Mdns.Server.Service{
      domain: get_domain(),
      data: ip_device,
      ttl: 120,
      type: :a
    })

    # ---------------------------------- Client ----------------------------------
    # Start the master client
    master = "master@#{get_domain()}" |> String.to_atom()
    Node.start(master)
  end

  # ---------------------------- Agents Operations ----------------------------
  def get_domain do Agent.get(@domain, &(&1)) end
  def get_connected do Agent.get(@connected, &(&1)) end
  def get_nodes do Agent.get(@nodes, &(&1)) end
  def update_connected(connected) do Agent.update(@connected, fn _ -> connected end) end
  def update_nodes(nodes) do Agent.update(@nodes, fn _ -> nodes end) end

  # ---------------------------------- Nodes ----------------------------------
  # get the node name 
  def node_name(nodes) do node_name(nodes, "node", 0, true) end
  def node_name(_nodes, name, index, false) do String.to_atom("#{name}#{index}") end
  def node_name(nodes, name, index, true) do
    key = String.to_atom("#{name}#{index+1}")
    has_key = Map.has_key?(nodes, key) 
    node_name(nodes, name, index+1, has_key)
  end

  # Dist.start
  # Dist.add("team", [])
  # Dist.get_nodes()
  def add(cookie, functions) do
    nodes = get_nodes()
    key = node_name(nodes)
    create_node(key, cookie)
    host = "#{key}@#{get_domain()}" |> String.to_atom()
    value = %{cookie: cookie, functions: functions, host: host}
    nodes |> Map.put_new(key, value) |> update_nodes()
  end

  # get domains of all distributed nodes
  def get_domains(name, domain) do get_domain_names(name, domain, 0, [], true) end
  def get_domain_names(_name, _domain, _index, domains, false) do domains end
  def get_domain_names(name, domain, index, domains, true) do
    host_name = "#{name}#{index+1}.#{domain}"
    dns = dns_hostname(host_name)
    domains = if dns do [host_name | domains] else domains end
    get_domain_names(name, domain, index+1, domains, dns)
  end

  # returns a new available domain name
  def new_domain_name(name, domain, index, true) do "#{name}#{index}.#{domain}" end 
  def new_domain_name(name, domain, index, false) do
    dns = !dns_hostname("#{name}#{index+1}.#{domain}")
    new_domain_name(name, domain, index+1, dns)
  end

  # validates if the domain is available
  def dns_hostname(domain_name) do
    {status, _} = domain_name |> String.to_atom() |> :net_adm.dns_hostname()
    case status, do: (:ok -> true; _ -> false)
  end

  # Create new node in different domain
  def create_node(node_name, cookie) do
    domain_name = get_domain()
    spawn(fn -> 
      System.cmd("iex", ["--name", "#{node_name}@#{domain_name}", "--cookie", "#{cookie}"]) 
    end)
  end

  # Dist.broadcast("team")
  def broadcast(cookie) do
    update_connected([])
    cookie |> String.to_atom() |> Node.set_cookie()
    get_domains(@host, @domain_name) |>
    Enum.each(fn domain ->
      Enum.each(1..@limit, fn node -> 
        node_name = "node#{node}@#{domain}" |> String.to_atom()
        status = Node.connect(node_name)
        if status do 
          Node.disconnect(node_name)
          connected_nodes = get_connected()
          update_connected([node_name | connected_nodes])
        end
      end)
    end)
    get_connected()
  end

  def stop() do
    Agent.stop(@nodes)
    Agent.stop(@domain)
  end


  # https://medium.com/blackode/deploying-elixir-modules-different-nodes-6c9cc17d3b97


  #spawn(fn -> System.cmd("iex.bat", []) end)
  #File.cwd!
  #File.mkdir!()

  #File.ls!
  #current_node = "Node1"
  #"#{File.cwd!}/#{current_node}" |> File.mkdir!
  #"#{File.cwd!}/#{current_node}" |> File.rmdir!
  #node_path = Enum.join([File.cwd!, "/Node1"], "")
  #node_path |> File.mkdir!
  #node_path |> File.rmdir!

  #cd!(node_path, spawn(fn -> System.cmd("iex.bat", []) end))

end

# :net_adm.names
# :net_adm.localhost
# :net_adm.dns_hostname(:localhost)
# :net_adm.dns_hostname(:"dist.local")