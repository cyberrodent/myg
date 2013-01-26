require 'log4r'
# include Log4r
require './lib/libraries'

do_logging = true
log_file = './log/app.log'

if do_logging
    #   log = File.new(log_file, "a")
    #   $stdout.reopen(log)
    #   $stderr.reopen(log)
    #   logger = Logger.new(log_file, 'daily')
    #   puts "Logging App in #{log_file}"
end

# use Rack::CommonLogger, logger
# use Mygoogle, logger
run Mygoogle::App.new


