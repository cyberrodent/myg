#
# Library file for mygoogle
#
# ----------------------------------------------------
require 'nokogiri'
require 'json'
require 'feedjira'
require 'sanitize'
require './lib/abstract_interface'
require './lib/mysql'
require './lib/mysql/userprefs'
require './lib/mysql/articles'




# Mg is a module to collect stuff for the MyGoogle web app
module Mg

    # We claim to be able to implement the userprefs interface
    include Userprefs

    # location of the xml file you exported from iGoogle  
    @pref_file = "./data/iGoogle-settings.xml"

    # will be the NokoGiri doc of the iGoogle prefs xml
    @doc = nil

    # How to connect to MySQL
    @mysql_opts = {
        :host => "localhost",
        :user => "myg",
        :pass => "myg!pass",
        :dbname => "mygoogle",
        :schema_file => "./myg.sql"
    }

    class << self

        attr_accessor :mysql_opts


        # Implement the Userprefs interfacce using Mysql
        def get_user_tabs(user_id)
            user_id = user_id || 1
            Mysql_userprefs.get_user_tabs(user_id)
        end

        def get_user_tab(tab_id)
            Mysql_userprefs.get_user_tab(1, tab_id)
        end

        def set_feed_name(tab_id, position, feed_name)
            user_id = 1
            Mysql_userprefs.set_feed_name(user_id, tab_id, position, feed_name)
        end

        def get_prefs(user_id)
            user_id = user_id || 1
            Mysql_userprefs.get_prefs(user_id)
        end

        def store_user_prefs(user_id, opts)
            user_id = user_id || 10
            Mysql_userprefs.store_user_prefs(user_id, opts)
        end





        # Methods related to handling the google XML pref file

        # read xml file and set @doc to the Nokogiri XML Document
        # Also remove namespces
        def init
            f = File.open(@pref_file)
            @doc = Nokogiri::XML(f)
            f.close
            @doc.remove_namespaces! 
        end

        # assumes @doc is set
        # returns array of these hashes 
        #   {
        #   :tabname => "tom", 
        #   :tabrss => [array,of,rss,urls,in,this,tab]
        #   }
        def read_prefs_xml
            myprefs =  [] # store our iGoogle tab data
            titles = @doc.xpath("//Tab")
            # o = ""
            titles.each {|t| 
                tabname = t.key?("title") ? t.xpath("@title") : false
                # We skip these 2 tabs: developer_tools and webmaster_tools
                if tabname && (tabname.text.downcase != 'developer tools' && tabname.text.downcase != 'webmaster tools')
                    temp_tab = []                 # o += "<h2>#{tabname}</h2>"
                    sections = t.xpath("Section")
                    sections.each {|s|            # o += "---- new section<br>\n" 
                        modules = s.xpath("Module") # o += "  --- NEW MODULE ----\n<br>"
                        modules.each {|m| 
                            modprefs = m.xpath("ModulePrefs[@xmlUrl]")
                            unless modprefs[0].nil? 
                                u = modprefs[0].attr('xmlUrl')
                                temp_tab << u           # o += "\t#{u}<br>\n"
                            end
                        }
                    }
                    myprefs << { 
                        :tabname => t['title'],
                        :tabrss  => temp_tab 
                    }
                end
            }
            myprefs
        end
        # Done with XML



        # Fetch and return a Feedjira feed object for the given URL
        # Sanitize it before returning.
        # Return nil if anything goes wrong.
        def fetch(url)
            options = {
                :timeout => 10
            }
            begin
                $logger.info("Fetching Feed #{url}")
                feed = Feedjira::Feed.fetch_and_parse(url, options)
            rescue
                # error with Feedjira Feed
                $logger.error "Fetch failure"
                return nil
            end

            begin
                $logger.info "Sanitizing"
                feed.sanitize_entries!
            rescue
                $logger.error "Problem sanitizing feed from #{url}. proceeding with nil." 
                return nil
            end

            feed
        end

        def _process_mysql(f)
            Mysqlarticle.process(f)
        end

        # _process
        # details of what we do when we process a feed
        # use this to kick off additional processing of the feed
        # - kicks off save each article to mysql archive
        def _process(tab_id, feed, how_many)
            show_this_many_summaries = how_many # show a summary for every article

            processed_feed = []
            if feed.nil?
                return processed_feed 
            end
            how_many = how_many - 1
            feed.entries[0 .. how_many ].each {|e|

                e_sum = e.summary
                es_len = 0
                unless e_sum.nil?
                    es_len = e.summary.length
                end

                e_con = e.content
                ec_len = 0
                unless e_con.nil?
                    ec_len = e.content.length
                end

                if (ec_len == 0) and (es_len == 0)
                    e_summary = ''
                else
                    if ec_len >= es_len
                        e_summary = e_con
                    else
                        e_summary = e_sum
                    end
                end

                summary = processed_feed.count < show_this_many_summaries ? (e_summary.nil? ? "" : e_summary)  : ""
                summary = Sanitize.clean(summary, { :attributes => { 'a' => ['href'] }}).strip

                if e.title.empty?
                    e.title = "untitled"
                end

                f = { 
                    'id' => Digest::MD5.hexdigest(e.url),
                    'feed_title' => feed.title.strip,
                    'title' => Sanitize.clean(e.title).strip,
                    'url'   => e.url,
                    'pubdate' => e.published,
                    'summary' => summary
                }

                processed_feed << f 

                # Kick off additional processing with mysql
                _process_mysql(f)
            }

            processed_feed
        end

        #
        # process 
        # tabs : tabs data array
        # gettab : only process tab matching this pattern
        # 
        def process(tabs, gettab = nil)
            tabs_parse = []
            process_limit = 10 # Max number of items per feed to process

            tabs.each {|tab|
                tab_name = tab[:tabname]
                # if there is a gettab value set then we
                # will get only that tab
                unless gettab.nil?
                    if gettab != tab_name.downcase
                        # skip it
                        next
                    end
                end
                temp = []
                position = 1
                tab[:tabrss].each {|feed|

                    $g.report('myg.fetch', 1)
                    start_time = Time.now
                    res = fetch(feed)
                    if res.nil?
                        next
                    end
                    feed_title = res.nil? ? "Untitled" : res.title
                    processed_feed = _process(tab[:tab_id], res, process_limit)

                    if processed_feed.nil?
                        $g.report('myg.fetch_error', 1)
                    else
                        self.set_feed_name(tab[:tab_id], position, processed_feed[0]['feed_title']) 
                    end
                    f = {
                        'id' => Digest::MD5.hexdigest(feed_title),
                        'feed_title' => feed_title,
                        'feed_data' => processed_feed
                    }
                    temp << f
                    position = position + 1
                    duration = Time.now - start_time
                    $g.report("myg.parsetime", duration)
                }

                tabs_parse << {
                    :tab_name => tab_name,
                    :tab_data => temp
                }
            } 
            return tabs_parse
        end





        # Older method - no longer needed
        # some endpoints will still call this
        #
        def parse(tabs, gettab = nil)


            raise "Don't be using this method anymore"

            start_time = Time.now

            num_feeds = 0 
            tabs_parse = []
            mytabs = {} # trying out storing it as a hash

            $g.report('myg.init', 1)

            tabs.each {|tab|
                tname = tab[:tabname]
                unless gettab.nil?
                    if gettab != tname.downcase
                        # $logger.info("Skipping #{tname}")
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

                    feed_title = res.empty? ? "Untitled Feed" : res.title

                    pfeed = processFeed(res, 10) 
                    f = { 
                        'id' => Digest::MD5.hexdigest(feed_title),
                        'feed_title' => feed_title,
                        'feed_data'  => pfeed 
                    }
                    tab_temp << f

                    mytabs[tname.downcase.to_sym] = f

                } # end of each tabrss

                tabs_parse << { 
                    'id' => tname,
                    'tab_name' => tname,
                    'tab_data' => tab_temp
                }
            } # end of all tabs

            duration = Time.now - start_time
            $logger.info("Parsed #{num_feeds} feed; took #{duration} seconds")
            $g.report("myg.parsetime", duration)

            return tabs_parse
        end

    end # end self class
end # end Mg Module
