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
            return "ACK"
        end

        get '/parse' do
            start_time = Time.now

            num_feeds = 0 

            tabs = parsePrefs()
            tabs_parse = []

            tabs.each {|tab|

                tab_temp = []

                tname = tab[:tabname] 
                $logger.info("Fetch RSS feeds in #{tname}")

                tab_feeds = 0
                tab[:tabrss].each {|rss|

                    # TODO
                    break if tab_feeds > 10
                    # break if num_feeds > 0
                    tab_feeds = tab_feeds + 1

                    $logger.info("\tFetching #{rss}")
                    res = fetchFeed(rss)

                    feed_title = res.nil? ? "untitled" : res.title
                    num_feeds = num_feeds + 1
                    pfeed = processFeed(res) 

                    tab_temp << { 
                        :feed_title => feed_title,
                        :feed_data  => pfeed 
                    }
                }
                tabs_parse << {
                    :tab_name => tname,
                    :tab_data => tab_temp
                    }
            }

            duration = Time.now - start_time
            $logger.info("Parsed #{num_feeds} feed; took #{duration} seconds")

            # return tabs_parse.inspect
            @tabs_parse = tabs_parse

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


