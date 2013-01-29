require 'nokogiri'

require 'sinatra/base'

module Mygoogle
    module Helpers

        @@logger  = nil

        def setup
            unless @@logger 
                logger = Log4r::Logger.new('APPLOG')
                logger.outputters << Log4r::FileOutputter.new('applog', :filename =>  '/tmp/app.log')
                logger.outputters << Log4r::Outputter.stdout

                @@logger = logger
            end
        end

        def mylog(str, level = "INFO")
            @@logger.info(str)
        end

        def parsePrefs
            pref_file = "./data/iGoogle-settings.xml"
            f = File.open(pref_file)
            @doc = Nokogiri::XML(f)
            f.close

            @doc.remove_namespaces!

            myprefs =  [] # store our iGoogle tab data
            
            titles = @doc.xpath("//Tab")
            # o = ""
            titles.each {|t| 
                tabname = t.key?("title") ? t.xpath("@title") : false
                if tabname 
                    temp_tab = []
                    # o += "<h2>#{tabname}</h2>"
                    sections = t.xpath("Section")
                    sections.each {|s| 
                        # o += "---- new section<br>\n" 
                        modules = s.xpath("Module")
                        # o += " ---- NEW MODULE ----\n<br>"
                        modules.each {|m| 
                            modprefs = m.xpath("ModulePrefs[@xmlUrl]")
                            unless modprefs[0].nil? 
                                u = modprefs[0].attr('xmlUrl')
                                temp_tab << u
                                # o += "\t#{u}<br>\n"
                            end
                        }
                    }
                    myprefs << { 
                        :tabname =>  t['title'],
                        :tabrss  => temp_tab 
                    } 
                end
            }
            myprefs
        end

        def fetchFeed(feed_url)
            feed = nil
            if feed_url
                feed = FeedTools::Feed.open(feed_url)
            end
            feed
        end


    end
end
