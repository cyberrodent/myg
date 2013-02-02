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
            mytabs = {}

            @tabs = parsePrefs()
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
            tabs = parsePrefs()

            @tabs_parse, @mytabs = parse tabs


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


