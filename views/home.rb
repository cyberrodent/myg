module Mygoogle::Views
   class Home < Layout



        def tabhash
            @mytabs
        end

        def tabhashkeys
            @mytabs.keys.map { |t| t.to_s }
        end


   end 
end
