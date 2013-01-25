module Mygoogle
    class App < Sinatra::Base
        register Mustache::Sinatra

        set :mustache, {
            :views => 'views/',
            :templates => 'templates/',
            :namespace => Mygoogle
        }

        set :public, "public/"
        set :static, true


        before do
            puts "before"
            pass
        end

        get '/' do
            return "ACK"
        end

        get '/*' do
            return "ALL"
        end

        error do 
            return "ERR"
        end

        after do
            puts "after"
            pass
        end

    end
end
