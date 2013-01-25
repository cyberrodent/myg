# Mygoogle
#
require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'mustache/sinatra'

base_dir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift base_dir unless $LOAD_PATH.include? base_dir

module Mygoogle
   class << self
        attr_accessor :stuff

        def new(app, logger)
            @@logger = logger
        end

        def initialize
            nil 
        end
   end
end
