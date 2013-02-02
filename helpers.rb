require 'nokogiri'

require 'sinatra/base'

module Mygoogle
    module Helpers

        def mylog(str, level = "INFO")
            $logger.info(str)
        end

        def parsePrefs
            start_time = Time.now

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

            duration = Time.now - start_time
            $g.report("myg.prefparsetime", duration)

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
            if feed.nil?
                return processed_feed
            end
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

        # fe
        def parse(tabs)

            $g.report('myg.init', 1)
            start_time = Time.now
            num_feeds = 0 
            tabs_parse = []
            mytabs = {}    # trying out storing it as a hash

            tabs.each {|tab|

                tname = tab[:tabname]
                tab_temp = []
                mytabs[tname.downcase.to_sym] = {}
                tab_feeds = 0

                $logger.info("Fetch RSS feeds in #{tname}")

                tab[:tabrss].each {|rss|

                    # TODO
                    break if tab_feeds > 1
                    # break if num_feeds > 0

                    $logger.info("\tFetching #{rss}")

                    res = self.fetchFeed(rss)

                    tab_feeds = tab_feeds + 1
                    num_feeds = num_feeds + 1

                    feed_title = res.nil? ? "untitled" : res.title

                    pfeed = processFeed(res) 
                    f = { 
                        :feed_title => feed_title,
                        :feed_data  => pfeed 
                    }
                    tab_temp << f

                    mytabs[tname.downcase.to_sym] = f

                } # end of each tabrss

                tabs_parse << { 
                    :tab_name => tname,
                    :tab_data => tab_temp
                }
            } # end of all tabs

            duration = Time.now - start_time
            $logger.info("Parsed #{num_feeds} feed; took #{duration} seconds")
            $g.report("myg.parsetime", duration)

            return [ tabs_parse , mytabs ]
        end



    end
end
