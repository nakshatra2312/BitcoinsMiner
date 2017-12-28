defmodule BitcoinMining.Mining.Crypto do
  
    def sha256(input) do
        :crypto.hash(:sha256, input)
    end

end