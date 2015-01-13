## Sets up global-ish things
# sets up logging
# graphite and statsd too
require 'rubygems'
require 'bundler'
Bundler.setup

base_dir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift base_dir unless $LOAD_PATH.include? base_dir

require 'benchmark'

# Pick a Feed handling library
# require 'feed_tools'
require 'feedjira'

# pick an in-memory cache
require 'redis'




require 'sinatra/base'
require 'mustache/sinatra'

require './helpers'
require './lib/app'
require './lib/mygoogle'
require "./views/layout"

#
# These should not be global nor hard coded, and yet...
#

# Global logger

require 'log4r'
include Log4r
$logger = Log4r::Logger.new('myg')
$logger.outputters << Log4r::FileOutputter.new('applog', :filename =>  '/tmp/app.log')
$logger.outputters << Log4r::Outputter.stdout

# Only show errors or worse (this ignores lots of warnngs and info)
$logger.level = Log4r::ERROR




# Global statsd
require "statsd"
$statsd = Statsd.new('machsheva.home', 8125)
$statsd.namespace = 'myp'
$statsd.count('init', 1)


# Global graphite
require "./lib/graphite"
$g = Graphite.new('machsheva.home')



