
require 'nokogiri'
require 'json'
require 'feedzirra'



# Mg is a module to collect stuff for the MyGoogle web app
module Mg


  @pref_file = "./data/iGoogle-settings.xml"
  @doc = nil
  @mysql_opts = {
    :host => "localhost",
    :user => "myg",
    :pass => "myg!pass",
    :dbname => "mygoogle",

    :schema_file => "./myg.sql"
  }
  class << self
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
        # We skip these 2 in our particular case
        if tabname && (tabname.text.downcase != 'developer tools' && tabname.text.downcase != 'webmaster tools')
          temp_tab = []                 # o += "<h2>#{tabname}</h2>"
          sections = t.xpath("Section")
          sections.each {|s|            # o += "---- new section<br>\n" 
            modules = s.xpath("Module") # o += " ---- NEW MODULE ----\n<br>"
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


    def dbconn(opts)
        require "mysql"
        begin
            db = Mysql.new(opts[:host], opts[:user], opts[:pass], opts[:dbname]);
        rescue Mysql::Error
            p("can't connect to this database: #{opts[:host]}")
            db = nil
        end
        db
    end





    # Public: mysql_store_user_prefs
    #
    # given the right input
    # store the user's preferences into the mysql backend
    # returns indicator of success tbd
    def mysql_store_user_prefs(opts)

        make_user_sql = "INSERT INTO users (`user_name`) VALUES ('jkolber')"
        last_insert_sql = "SELECT LAST_INSERT_ID()"
        clear_user_tab_sql = "DELETE FROM `user_tab` WHERE user_id=?"
        add_tab_sql = "INSERT INTO user_tab (user_id, tab_name) VALUES (?, ?)"

        
        
        begin
            db = dbconn(@mysql_opts)

            # make_user = db.prepare(make_user_sql)
            # make_user.execute
            # last_id = db.query(last_insert_sql)
            # p last_id

            clear_tabs = db.prepare(clear_user_tab_sql)
            clear_tabs.execute 1

            add_tab = db.prepare(add_tab_sql)

            opts.each { |tab|

                
                add_tab.execute 1, tab[:tabname] 
                p tab[:tabname]
                p tab[:tabrss].join(" ")
            }
        ensure
            db.close
        end
    end

    def fetch(url)
        options = {
            :timeout => 10
        }
        begin
            puts "fetching Feed #{url}"
            feed = Feedzirra::Feed.fetch_and_parse(url, options)

        rescue
            # error with Feedzirra Feed
            puts "fetch failure"
            return nil
        end
        begin
            puts "sanitizing"
            feed.sanitize_entries!
        rescue
            puts "problem sanitizing feed. proceeding" 
        end

        feed
    end

    def _process(feed, how_many)
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
            processed_feed
    end

    def process(tabs, gettab = nil)
        tabs_parse = []
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

            tab[:tabrss].each {|feed|

                res = fetch(feed)
                feed_title = res.nil? ? "untitled" : res.title
                processed_feed = _process(res, 10)
                f = {
                    'feed_title' => feed_title,
                    'feed_data' => processed_feed
                }
                temp << f
            }

            tabs_parse << {
                :tab_name => tab_name,
                :tab_data => temp
            }
        } 

        tabs_parse
    end

    
  end # end self class
end # end Mg Module
