require 'sinatra/base'
require 'mustache/sinatra'
require 'json'

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
            xmldoc = Mg.init

            # Phasing out the xml @tabs = Mg.read_prefs_xml
            @tabs = Mg.mysql_get_prefs

            @redis = Redis.new
            # TODO: get this from a login or something
            @user_key = "kolber01"
        end

        get '/' do
            @tabs_mysql = Mg.mysql_get_user_tabs
            mustache :home  
        end

        get '/tabs/:tname' do |tname|
            tab_key = "#{@user_key}-#{tname}"
            res = @redis.get(tab_key)
            if res.nil?
                @tabs_parse, @mytabs = parse(@tabs, tname)
                json_data = @tabs_parse.to_json
                @redis.set(tab_key, json_data)
            else
                @tabs_parse = JSON.parse(res)
            end
            mustache :singletab
        end

        get '/fetch/all' do
            out = ""
            @tabs_parse, @mytabs = parse(@tabs)
            @tabs_parse.each{|tab|
                out += tab['tab_name']
                tname = tab['tab_name'].downcase
                tab_key = "#{@user_key}-#{tname}"
                json_data = tab.to_json
                @redis.set(tab_key, json_data)
                out += "<hr />"
            }
            out 
        end

        get '/fetch/:tname' do |tname|

            @tabs_parse, @mytabs = parse(@tabs, tname.downcase)
            out = @tabs_parse[0]['tab_name']
            tab_key = "#{@user_key}-#{tname}"
            json_data = @tabs_parse[0].to_json
            @redis.set(tab_key, json_data)
            "ok: #{out}"
        end

        get '/raw/:tname' do |tname|
            @tabs_parse, @mytabs = parse(@tabs, tname)
            return @tabs_parse.inspect
        end


        get '/parse' do
            @tabs_parse, @mytabs = parse @tabs
            @redis.set(@user_key, @tabs_parse)
            mustache :parse 
        end





        # ---- catch all, errors and after ---- #
        get '/*' do
            return "CATCH ALL"
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


