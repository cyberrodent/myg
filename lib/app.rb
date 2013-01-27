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
            # puts "before"
            # @@logger.info("before")
            pass
        end

        get '/' do
            return "ACK"
        end

        get '/parse' do
            tabs = parsePrefs()
            tabs.inspect 
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
