defmodule BitcoinMining.Mining.Miner do
    use GenServer
    alias BitcoinMining.Mining.Crypto  
    alias BitcoinMining.Mining.ZeroMatching 

    def start_link(name) do        
        GenServer.start_link(__MODULE__, %{}, name: name)        
    end

    def handle_cast({:find_coins, node_name, miner_name, start_range, k}, state) do
        end_range = start_range + 1000000
        name = "mohitmewara;"
        list = for n <- start_range..end_range, do: name <> Base.encode64(to_string(n))              
        list |> (Enum.each fn(x) ->                        
            hash = Crypto.sha256(x) |> Base.encode16
            zero = ZeroMatching.findZero(String.to_charlist(hash),0)              
            if zero >= k do
                send :global.whereis_name(:server), {node_name, "value", x <> " " <>hash}
            end            
        end)             
        send :global.whereis_name(:server), {node_name, "retry", miner_name}              
        {:noreply, state}
    end

end