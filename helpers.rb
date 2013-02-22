require 'nokogiri'

require 'sinatra/base'

module Mygoogle
    module Helpers

        #
        # Wrapper to some imaginary and ideal global logging utility
        #
        def mylog(str, level = "INFO")
            # $logger.info(str)
        end

        #
        # parsePrefs() parse the igoogle xml settings file
        # Returns a hash with  :tabname and :tabrss as the keys
        #
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
                # We skip these 2 in our particular case
                if tabname && (tabname.text.downcase != 'developer tools' && tabname.text.downcase != 'webmaster tools')
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

        #
        # fetchFeed(feed_url) -  fetch a RSS/Atom feed
        # Returns a sanitized Feedzirra Feed
        #
        def fetchFeed(feed_url)

            $g.report('myg.fetch', 1)
            $statsd.increment('fetch', 1)


            feed = nil
            fetch_options = {
                :timeout => 10
            }

            begin 
                start_time = Time.now
                feed = Feedzirra::Feed.fetch_and_parse(feed_url, fetch_options)
                duration = Time.now - start_time
                duration_ms = duration * 1000
                $logger.info("\tFetch took #{duration}") 
                $statsd.timing('fetching', "#{duration_ms}")
            rescue
                $logger.error("fetchFeed !!!!!! FAILED !!!!!!! on #{feed_url}")
                $g.report('myg.fetch_error', 1)
                return nil
            end

            begin
                original_feed = feed # keep an unsanitized copy in case we need it later
                feed.sanitize_entries!
                # $logger.info("Fetched Feed: #{feed.title}")
                # $logger.info("counted #{feed.entries.length} articles")
            rescue
                $logger.error("Exception sanitizing a fetched feed: #{original_feed.inspect}")
                return nil
            end

            feed
        end

        #
        # processFeed(feed, how_many) - returns the first how_many items from the feed as an
        # array of a renderable hashes like these:
        # 'feed_title' => feed.title,
        # 'title' => e.title,
        # 'url'   => e.url,
        # 'pubdate' => e.published,
        # 'summary' => processed_feed.count < how_many ? e.summary  : ""

        # 
        def processFeed(feed, how_many = 6)

            show_this_many_summaries = how_many # show a summary for every article
            processed_feed = []
            if feed.nil?
                return processed_feed
            end
            how_many = how_many - 1
            feed.entries[0 .. how_many ].each {|e|
                processed_feed << { 
                    'feed_title' => feed.title,
                    'title' => e.title,
                    'url'   => e.url,
                    'pubdate' => e.published,
                    'summary' => processed_feed.count < show_this_many_summaries ? (e.summary.nil? ? "" : e.summary)  : ""
                }
            }
            
            # $logger.debug(processed_feed[0])
            processed_feed
        end

        #
        # parse(tabs, gettab) - fetch and parse feeds
        # defaults to all feeds unless you tell me a feed to get
        # Returns an array of 2 elements, each a data structure
        # representing the parsed feed.
        #
        def parse(tabs, gettab = nil)
            start_time = Time.now

            num_feeds = 0 
            tabs_parse = []
            mytabs = {} # trying out storing it as a hash

            $g.report('myg.init', 1)

            tabs.each {|tab|
                tname = tab[:tabname]
                unless gettab.nil?
                    if gettab != tname.downcase
                        $logger.info("Skipping #{tname}")
                        next
                    end
                end

                $logger.info("Fetch RSS feeds in #{tname}")

                tab_temp = []
                mytabs[tname.downcase.to_sym] = {}
                tab_feeds = 0

                tab[:tabrss].each {|rss|

                    # FIXME
                    # next if tab_feeds > 2 

                    $logger.info("\tFetching #{rss}")

                    res = fetchFeed(rss)

                    tab_feeds = tab_feeds + 1
                    num_feeds = num_feeds + 1

                    feed_title = res.nil? ? "untitled" : res.title

                    pfeed = processFeed(res, 10) 
                    f = { 
                        'feed_title' => feed_title,
                        'feed_data'  => pfeed 
                    }
                    tab_temp << f

                    mytabs[tname.downcase.to_sym] = f

                } # end of each tabrss

                tabs_parse << { 
                    'tab_name' => tname,
                    'tab_data' => tab_temp
                }
            } # end of all tabs

            duration = Time.now - start_time
            $logger.info("Parsed #{num_feeds} feed; took #{duration} seconds")
            $g.report("myg.parsetime", duration)

            return [ tabs_parse , mytabs ]
        end

    end
end
