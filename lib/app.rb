require 'sinatra/base'
require 'mustache/sinatra'
require 'json'

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

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

        set :show_exceptions, true

        before do
            @user_key = "kolber01" # TODO: get this from somewhere
            fake_user_id = 1

            # the list of tabs for the given user id
            @tabs = Mg.get_prefs fake_user_id
            @tabs_data = Mg.get_user_tabs fake_user_id

            # set up our cache
            @redis = Redis.new
        end


        get '/' do
            mustache :home
        end


        get '/tabs/list' do
            # returns [ {"tabname":"Home","tab_id":1,"tabrss": [..] } .. ]  for each of this user's tabs.
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            @tabs.to_json
        end


        get '/tabs/:tname' do |tname|
            # Check the cache first
            tab_key = "#{@user_key}-#{tname.downcase}"
            res = @redis.get(tab_key)
            if res.nil?
                @tabs_parse = Mg.process(@tabs, tname.downcase)
                json_data = @tabs_parse.to_json
                @redis.set(tab_key, json_data)
            else
                @tabs_parse = JSON.parse(res)
            end
            mustache :singletab
        end


        get '/json/:tname' do |tname|
            tab_key = "#{@user_key}-#{tname.downcase}"
            res = @redis.get(tab_key)
            if res.nil?
                @tabs_parse = Mg.process(@tabs, tname.downcase)
                json_data = @tabs_parse.to_json
                @redis.set(tab_key, json_data)
            end
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            res
        end


        get '/json/tab/:tab_id' do |tab_id|
            data = Mg.get_user_tab(tab_id)
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            return data.to_json
        end


        get '/tabdata/all' do
            aggres = []
            @tabs.each{|tab|
                tname = tab[:tabname].downcase
                tab_key = "#{@user_key}-#{tname}"
                res = @redis.get(tab_key)
                if res.nil?
                    @tabs_parse = parse(@tabs, tname)
                    res = @tabs_parse.to_json
                    @redis.set(tab_key, res)
                end
                aggres << JSON.parse(res)
            }
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            aggres.to_json
        end

        get '/tabdata/:tname' do |tname|
            tab_key = "#{@user_key}-#{tname}"
            res = @redis.get(tab_key)
            if res.nil?
                @tabs_parse = parse(@tabs, tname)
                res = @tabs_parse.to_json
                @redis.set(tab_key, res)
            else
                @tabs_parse = JSON.parse(res, :external_encoding => 'iso-8859-1')
            end
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            [@tabs_parse].to_json
        end


       get '/fetch/all' do
            out = ""
            @tabs_parse = Mg.process(@tabs)
            @tabs_parse.each{|tab|
                out += tab[:tab_name]
                tname = tab[:tab_name].downcase
                tab_key = "#{@user_key}-#{tname}"
                json_data = tab.to_json
                @redis.set(tab_key, json_data)
                out += "<hr />"
            }
            out
        end

        get '/fetch/:tname' do |tname|
            @tabs_parse = Mg.process(@tabs, tname.downcase)
            out = @tabs_parse[0][:tab_name]
            tab_key = "#{@user_key}-#{tname.downcase}"
            json_data = @tabs_parse[0].to_json
            @redis.set(tab_key, json_data)
            "ok: #{out} #{json_data}"
        end

        get '/raw/:tname' do |tname|
            @tabs_parse = Mg.parse(@tabs, tname.downcase)
            @tabs_parse.inspect
        end


        get '/parse' do
            @tabs_parse = Mg.parse @tabs
            @redis.set(@user_key, @tabs_parse)
            mustache :parse
        end

        get '/googlenews' do

            mustache :googlenews
        end

        get '/settings' do
            return "SETTINGS PAGE WILL BE HERE"
        end



        # ---- catch all, errors and after ---- #

        get '/*' do
            return "CATCH ALL"
        end

#        error do
#            return "Some sort of error occurred."
#        end

        after do
            # is there anything to do after?
            pass
        end

    end
end
