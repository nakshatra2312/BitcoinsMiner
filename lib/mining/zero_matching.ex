defmodule BitcoinMining.Mining.ZeroMatching do  
 
    def findZero([head | tail], max_length) when head == 48 do            
            findZero(tail, max_length+1) 
        end
    def findZero([_ | _], max_length) do max_length end

end