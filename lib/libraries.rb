require 'rubygems'
require 'bundler'
Bundler.setup

require 'benchmark'

# Pick a Feed handling library
# require 'feed_tools'
require 'feedzirra'

# Pick a logging library
require 'log4r'
include Log4r

require "statsd"

require 'sinatra/base'
require 'mustache/sinatra'

base_dir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift base_dir unless $LOAD_PATH.include? base_dir




require './helpers'
require './lib/app'
require './lib/mygoogle'
require "./lib/graphite"


# Setup a global logger
$logger = Log4r::Logger.new('APPLOG')
$logger.outputters << Log4r::FileOutputter.new('applog', :filename =>  '/tmp/app.log')
$logger.outputters << Log4r::Outputter.stdout

# setup a global statsd
$statsd = Statsd.new('machsheva.home', 8125)
$statsd.namespace = 'myp'
$statsd.count('init', 1)

$g = Graphite.new('machsheva.home')
$g.report('myg.init', 1)

