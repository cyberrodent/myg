require 'log4r'
# include Log4r
require './lib/mygoogle'
require './lib/app'

do_logging = true
log_file = './log/app.log'

if do_logging

    logger = Log4r::Logger.new('applog')
    logger.outputters << Log4r::FileOutputter.new('applog', :filename =>  '/tmp/app.log')
    logger.outputters << Log4r::Outputter.stdout
    logger.info("start")

    #   log = File.new(log_file, "a")
    #   $stdout.reopen(log)
    #   $stderr.reopen(log)
    #   logger = Logger.new(log_file, 'daily')
    #   puts "Logging App in #{log_file}"
end


use Rack::CommonLogger, logger
use Mygoogle, logger
run Mygoogle::App.new


