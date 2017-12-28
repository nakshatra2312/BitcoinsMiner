defmodule BitcoinMining do
  
  alias BitcoinMining.Mining.Miner
  alias BitcoinMining.Mining.Listener
  alias BitcoinMining.Mining.Supervisor

  def main(args \\ []) do    
    args
    |> parse_string
    
    receive do
      { :stop } -> 
        IO.puts "DONE"
        
    end    
  end

  defp parse_string(args) do
    if Regex.match?(~r/\./, to_string(args)) do
      node_name = Enum.at(args,0)      
      IO.puts node_name
      local_address = find_local_address()
      client_name = generate_client_name("mohit-client", local_address)      
      server_name = "mohit-server@" <> node_name
      start_distributed(client_name)
      Node.connect(:"#{server_name}")
      {:ok, _} = Supervisor.start_link 
      Miner.start_link(:miner1)      
      :global.sync()      
      send :global.whereis_name(:server), {client_name, "connect", :miner1}
      no_of_cores = :erlang.system_info(:schedulers_online)
      add_and_start_additional_workers(2, 2 * no_of_cores, client_name)      
    else      
      {k,_} = Integer.parse(Enum.at(args,0))      
      local_address = find_local_address()   
      server_name = :"mohit-server@#{local_address}"      
      start_distributed(server_name)
      {:ok, server} = Listener.start_link(k)
      :global.register_name(:server, server)      
      {:ok, _} = Supervisor.start_link
      Miner.start_link(:miner1)           
      send :global.whereis_name(:server), {server_name, "connect", :miner1}
      no_of_cores = :erlang.system_info(:schedulers_online)
      add_and_start_additional_workers(2, 2 * no_of_cores, server_name)
    end
  end

  defp find_local_address do
    {:ok, all_ip} = :inet.getif()
    all_ip_tuple = Enum.filter(all_ip, fn(x) ->  
      #Enum.join(Tuple.to_list(Enum.at(Tuple.to_list(x), 0))) not in ["127001", "0000", "255000"]
      Enum.join(Tuple.to_list(Enum.at(Tuple.to_list(x), 0))) != "127001"
    end)
    ip_tuple = Enum.at(Tuple.to_list(Enum.at(all_ip_tuple,0)),0)
    :inet.ntoa(ip_tuple)
  end

  defp add_and_start_additional_workers(index, count, node_name) do
    if count > 1 do
      worker_name = :"miner#{index}"      
      Supervisor.add_miner(worker_name)      
      send :global.whereis_name(:server), {node_name, "additional_node", worker_name}
      add_and_start_additional_workers(index + 1, count - 1, node_name)
    end  
  end

  def start_distributed(appname) do
    unless Node.alive?() do
      {:ok, _} = Node.start(appname)
    end       
    Node.set_cookie(:cookieName)    
  end

  defp generate_client_name(name, node_name) do    
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(256) |>
      Integer.to_string(16)
    String.to_atom("#{name}-#{hex}@#{node_name}")
  end  

end
