# Mygoogle
#
require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'mustache/sinatra'
require 'logger'

base_dir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift base_dir unless $LOAD_PATH.include? base_dir

module Mygoogle
   class << self
        attr_accessor :stuff
        attr_accessor :logger

        def initialize
            @logger = Logger.new('./lib/app.log', 'daily')
        end
   end
end
