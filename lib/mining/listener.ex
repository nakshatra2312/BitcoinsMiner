defmodule BitcoinMining.Mining.Listener do   

    def start_link(k) do
        Task.start_link(fn -> receiver(1, k) end)
    end

    defp receiver(start_range, k) do            
        receive do
            {node, type, message_or_worker_name} -> 
                cond do
                    type == "connect" ->
                        IO.puts "Connected to Node: #{inspect node}"
                        IO.puts "Bitcoin mining started for Node #{inspect node}"
                        assign_work(node, message_or_worker_name, start_range, k)                        
                    type == "value" ->
                        {:ok, file} = File.open "bitcoins_mined.txt", [:append]
                        IO.binwrite file, [message_or_worker_name <> "\n"] 
                        File.close file 
                        IO.puts message_or_worker_name
                        #System.halt(0)
                    type == "retry" ->
                        assign_work(node, message_or_worker_name, start_range, k)                        
                    type == "additional_node" ->                        
                        assign_work(node, message_or_worker_name, start_range, k)
                end 
             receiver(start_range + 1000001, k)       
        end  
    end

    defp assign_work(node, miner_name, start_range, k) do    
        GenServer.cast({miner_name, node}, {:find_coins, node, miner_name, start_range, k})
    end

end