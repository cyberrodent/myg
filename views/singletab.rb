module Mygoogle::Views
    class Singletab < Layout

        def tabhash
            @mytabs
        end

        def tabhashkeys
            @mytabs.keys.map { |t| t.to_s }
        end

        def pt
            max_character_count_for_summary = 200
            @tabs_parse.each{ |tab|
                
                tab[1].each { |feed|
                    # puts "     __ #{feed['feed_title']} "
                    if !feed['feed_data'].nil? 
                        if !feed['feed_data'][0].nil?
                            feed['feed_data'][0]['summary'] = feed['feed_data'][0]['summary'].gsub(/<\/?[^>]*>/, "")[0 .. max_character_count_for_summary]
                        end
                    end
                }
            }
        end
    end 
end
