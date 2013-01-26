require 'rubygems'
require 'bundler'
Bundler.setup

require 'log4r'
include Log4r

require 'sinatra/base'
require 'mustache/sinatra'


base_dir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift base_dir unless $LOAD_PATH.include? base_dir

require './helpers'
require './lib/app'
require './lib/mygoogle'


