defmodule MyNode do
  def hello do
    IO.puts "hi !! #{Node.self()}"
  end

  # cd ".\dist\lib\"
  # elixirc ".\mynode.ex"
  # nl([:"node1@machine1.local"], MyNode)
  # Node.spawn_link(:"node1@machine1.local", fn -> MyNode.nodes end)
  def nodes do
    IO.inspect(Node.list)
  end

  def get_self do
    IO.inspect(self())
  end

end