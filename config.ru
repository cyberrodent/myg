require 'logger'
require './lib/mygoogle'
require './lib/app'

do_logging = true
log_file = './log/app.log'

if do_logging
    log = File.new(log_file, "a")
    $stdout.reopen(log)
    $stderr.reopen(log)
    logger = Logger.new(log_file, 'daily')
    puts "Logging App in #{log_file}"
end
use Rack::CommonLogger, logger
run Mygoogle::App.new
