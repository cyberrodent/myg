# Mygoogle
#
module Mygoogle
   class << self
        attr_accessor :stuff

        def new(app)

            logger = Log4r::Logger.new('applog')
            logger.outputters << Log4r::FileOutputter.new('applog', :filename =>  '/tmp/app.log')
            logger.outputters << Log4r::Outputter.stdout
            logger.info("start")


            @logger = logger
        end

        def initialize
            nil 
        end
   end
end
