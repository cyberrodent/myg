module Mygoogle::Views
    class Parse < Layout

        def tabs
            @tabs_parse
        end

        def tabhash
            @mytabs
        end

        def tabhashkeys
            @mytabs.keys.map { |t| t.to_s }
        end
    end
end
