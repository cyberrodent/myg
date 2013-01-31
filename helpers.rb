require 'nokogiri'

require 'sinatra/base'

module Mygoogle
    module Helpers

        def mylog(str, level = "INFO")
            $logger.info(str)
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
            timeout_in_seconds = 9
            $g.report('myg.fetch' ,1)
            $statsd.increment('fetch', 1)
            feed = nil
            fetch_options = {
                :timeout => 10
            }

            begin 
                start_time = Time.now

                feed = Feedzirra::Feed.fetch_and_parse(feed_url, fetch_options)

                duration = Time.now - start_time
                $logger.info("Fetch took #{duration}") 

                duration_ms = duration * 1000
                $statsd.timing('fetching', "#{duration_ms}")

            rescue
                $logger.error("fetchFeed !!!!!! FAILED !!!!!!! on #{feed_url}")
                $g.report('myg.fetch_error', 1)
                return nil
            end
            begin

                original_feed = feed
                feed.sanitize_entries!
                # $logger.info("Fetched Feed: #{feed.title}")
                # $logger.info("counted #{feed.entries.length} articles")
            rescue
                $logger.error("Exception with fetched feed: #{original_feed.inspect}")
                return nil
            end


            feed
        end



        def processFeed(feed, how_many = 6)
            processed_feed = []
            feed.entries[0..how_many].each {|e|
                processed_feed << { 
                    :feed_title => feed.title,
                    :title => e.title,
                    :url   => e.url,
                    :summary => processed_feed.count < 1 ? e.summary  : ""
                }
            }
            
            # $logger.debug(processed_feed[0])
            processed_feed
        end
    end
end
