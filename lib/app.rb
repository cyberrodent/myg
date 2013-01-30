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

            o = ''

            tabs = parsePrefs()

            tabs.each {|tab|

                $logger.info("Fetch RSS feeds in #{tab[:tabname]}")
                tab[:tabrss].each {|rss|
                   o += rss
                   $logger.info("\tFetching #{rss}")
                   res = fetchFeed(rss)
                   
                   # unless res.nil? $logger.info(res.last_modified); end
                   
                } 
            }

            return o
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


