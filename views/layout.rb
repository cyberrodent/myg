module Mygoogle
    module Views
        class Layout < Mustache

            def tabhash
                @mytabs
            end

            def tabhashkeys
                @mytabs.keys.map { |t| t.to_s }
            end

        end
    end
end
