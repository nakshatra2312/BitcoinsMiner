defmodule BitcoinMining.Mining.Supervisor do
    use Supervisor
    alias BitcoinMining.Mining.Miner    

    def start_link do        
        Supervisor.start_link(__MODULE__, [],  name: :miner_supervisor)       
    end

    def init(_) do
        children = 
        [            
            worker(Miner, []),                        
        ]        
        supervise(children, strategy: :simple_one_for_one)        
    end

    def add_miner(name) do        
        Supervisor.start_child(:miner_supervisor, [name])        
    end
end
