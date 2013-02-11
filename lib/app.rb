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
            @tabs = parsePrefs()
            @redis = Redis.new

            @user_key = "kolber01"

        end

        get '/' do
            mytabs = {}
            @tabs.each {|tab|
                tname = tab[:tabname]
                mytabs[tname.downcase.to_sym] = {
                   'tab_name' => tname,
                   'tab_data' => []    
                }
            }
            @mytabs = mytabs

            mustache :home  
        end

        get '/tabs/:tname' do |tname|
            @tabs_parse, @mytabs = parse(@tabs, tname)

            tab_key = "#{@user_key}-#{tname}"
            @redis.set(tab_key, @tabs_parse)

            mustache :singletab

        end

        get '/parse' do
            @tabs_parse, @mytabs = parse @tabs

            @redis.set(@user_key, @tabs_parse)

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


