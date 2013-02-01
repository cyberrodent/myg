require 'sinatra/base'
require 'mustache/sinatra'

module Mygoogle

    class App < Sinatra::Base
        register Mustache::Sinatra

        helpers Mygoogle::Helpers

        set :mustache, {
            :views => 'views/',
            :templates => 'templates/',
            :namespace => Mygoogle
        }

        set :public_folder, "public/"
        set :static, true

        before do
            # setup()
            # puts "before"
            # $logger.info("before")
            pass
        end

        get '/' do
            prefs = parsePrefs()
            mytabs = {}

            tabs = parsePrefs()
            tabs.each {|tab|
                tname = tab[:tabname]
                mytabs[tname.downcase.to_sym] = {
                   :tab_name => tname,
                   :tab_data => []    
                }
            }
            @mytabs = mytabs

            mustache :home  
        end

        get '/tabs/:tname' do |tname|

            "well. #{tname} how was that?" 
        end

        get '/parse' do
            $g.report('myg.init', 1)
            start_time = Time.now
            num_feeds = 0 
            tabs_parse = []
            mytabs = {}    # trying out storing it as a hash

            tabs = parsePrefs()
            tabs.each {|tab|

                tname = tab[:tabname]
                tab_temp = []
                mytabs[tname.downcase.to_sym] = {}
                tab_feeds = 0
                
                $logger.info("Fetch RSS feeds in #{tname}")

                tab[:tabrss].each {|rss|

                    # TODO
                    break if tab_feeds > 1
                    # break if num_feeds > 0

                    $logger.info("\tFetching #{rss}")

                    res = fetchFeed(rss)

                    tab_feeds = tab_feeds + 1
                    num_feeds = num_feeds + 1

                    feed_title = res.nil? ? "untitled" : res.title

                    pfeed = processFeed(res) 
                    f = { 
                        :feed_title => feed_title,
                        :feed_data  => pfeed 
                    }
                    tab_temp << f

                    mytabs[tname.downcase.to_sym] = f

                } # end of each tabrss

                tabs_parse << { 
                    :tab_name => tname,
                    :tab_data => tab_temp
                }
            } # end of all tabs

            duration = Time.now - start_time
            $logger.info("Parsed #{num_feeds} feed; took #{duration} seconds")
            $g.report("myg.parsetime", duration)

            @tabs_parse = tabs_parse
            @mytabs = mytabs
            mustache :parse 
        end





        # ---- catch all, errors and after ---- #
        get '/*' do
            return "ALL"
        end

        error do 
            return "ERR"
        end

        after do
            # puts "after"
            pass
        end

    end
end


