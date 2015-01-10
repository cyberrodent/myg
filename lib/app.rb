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

        before do
            @user_key = "kolber01" # TODO: get this from somewhere
            @tabs = Mg.get_prefs(1)
            @tabs_data = Mg.get_user_tabs(1)
            @redis = Redis.new
        end

        get '/' do
            mustache :home
        end

        get '/tabs/list' do
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            @tabs.to_json
        end


        get '/json/:tname' do |tname|
            tab_key = "#{@user_key}-#{tname}"
            res = @redis.get(tab_key)
            if res.nil?
                @tabs_parse = parse(@tabs, tname)
                res = @tabs_parse.to_json
                @redis.set(tab_key, res)
            end
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            res
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

        get '/tabs/:tname' do |tname|

            tab_key = "#{@user_key}-#{tname}"
            res = @redis.get(tab_key)
            if res.nil?
                @tabs_parse = parse(@tabs, tname)
                json_data = @tabs_parse.to_json
                @redis.set(tab_key, json_data)
            else
                @tabs_parse = JSON.parse(res)
            end
            mustache :singletab
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
            tab_key = "#{@user_key}-#{tname}"
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



        get '/json/tab/:tab_id' do |tab_id|
            data = Mg.get_user_tab(tab_id)
            headers "Access-Control-Allow-Origin" => "*"
            headers "Content-Type" => "application/json; charset=utf8"
            return data.to_json
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
