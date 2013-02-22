module Mygoogle::Views
    class Singletab < Layout

        def tabhash
            @mytabs
        end

        def tabhashkeys
            @mytabs.keys.map { |t| t.to_s }
        end

        def pt
            @tabs_parse.each{ |tab|
                puts "++++++"
                tab[1].each { |feed|
                    puts "     __ #{feed['feed_title']} "
                    if !feed['feed_data'].nil? 
                        if !feed['feed_data'][0].nil?
                            feed['feed_data'][0]['summary'] = feed['feed_data'][0]['summary'].gsub(/<\/?[^>]*>/, "")[0 .. 40]
                        end
                    end
                }
            }
        end
    end 
end
