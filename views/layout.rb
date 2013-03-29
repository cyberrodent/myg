module Mygoogle
    module Views
        class Layout < Mustache

            def tabhash
                @mytabs
            end

            def tabhashkeys
                @mytabs.keys.map { |t| t.to_s }
            end

            def pt
                @tabs_parse
            end

            def mysql_tablist
                @tabs_mysql
            end
        end
    end
end
