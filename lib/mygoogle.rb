# ----------------------------------------------------
#
# Library file for mygoogle (igoogle replacement)
#
# ----------------------------------------------------
require 'nokogiri'
require 'json'
require 'feedzirra'
require 'sanitize'


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

  # SQL QUERIES GENERAL
  @@last_insert_sql = "SELECT LAST_INSERT_ID()"
  @@feed_report = "SELECT a.*, b.tab_name FROM feeds a, user_tab b WHERE a.tab_id=b.tab_id AND a.user_id = b.user_id"
  @@get_user_sql = "SELECT b.tab_name , a.position, a.url FROM feeds a, user_tab b WHERE a.tab_id=b.tab_id AND a.user_id = b.user_id AND a.user_id=? ORDER BY a.tab_id, a.position"
  @@get_user_tab_sql = "SELECT b.tab_name , a.position, a.url FROM feeds a, user_tab b WHERE a.tab_id=b.tab_id AND a.user_id = b.user_id AND a.user_id=? AND a.tab_id=? ORDER BY a.tab_id, a.position"

  # SQL QUERIES users TABLE
  @@make_user_sql = "INSERT INTO users (`user_name`) VALUES ('jkolber')"

  # SQL QUERIES user_tab TABLE
  @@add_tab_sql =        "INSERT INTO user_tab (user_id, tab_id, tab_name) VALUES (?, ?, ?)"
  @@clear_user_tab_sql = "DELETE FROM `user_tab` WHERE user_id=?"
  @@get_tabs_sql = "SELECT tab_name FROM user_tab WHERE user_id = ? ORDER BY tab_id"

  # SQL QUERIES feeds TABLE
  @@clear_user_feeds_sql = "DELETE FROM `feeds` WHERE user_id=? AND tab_id=?"
  @@add_feed_sql =         "INSERT INTO feeds (`user_id`, `tab_id`, `position`, `url`) VALUES (?, ?, ?, ?)"

  # SQL QUERIES articles TABLE
  @@add_article_sql = "INSERT INTO article (`feed_name`, `title`, `summary`, `url`, `pubdate_timestamp`) VALUES (?, ?, ?, ?, ?)"

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

    def mysql_get_user_tabs
        begin
            res = []
            db = dbconn(@mysql_opts)
            user_id = 1
            get_user = db.prepare(@@get_tabs_sql)
            get_user.execute user_id

            while row = get_user.fetch do
                res << row[0]
            end
        end
        res
    end

    def mysql_get_user_tab(tab_id)
        begin 
            res = []
            db = dbconn(@mysql_opts)
            user_id = 1
            get_user = db.prepare(@@get_user_tab_sql)
            get_user.execute user_id, tab_id

            while row = get_user.fetch do
                res << row
            end
        end
        res
    end


    def mysql_get_prefs
        begin 
            res = []
            db = dbconn(@mysql_opts)
            user_id = 1 ## FIXME THIS
            get_user = db.prepare(@@get_user_sql)
            get_user.execute user_id
            last_tab = ""
            idx = -1
            while row = get_user.fetch do
                if row[0] != last_tab
                    idx = idx + 1
                    obj = {
                        :tabname => row[0],
                        :tabrss => [] 
                    }
                    res << obj
                end
                # find the obj at res[idx] and push row[2] onto :tabrss
                res[idx][:tabrss] << row[2]
                last_tab = row[0]
            end
        end
        res 
    end

    # Public: mysql_store_user_prefs
    #
    # given the right input
    # store the user's preferences into the mysql backend
    # returns indicator of success tbd
    def mysql_store_user_prefs(opts)
        begin
            db = dbconn(@mysql_opts)

            user_id = 1 # TODO

            # todo: move me
            # make_user = db.prepare(make_user_sql)
            # make_user.execute
            # last_id = db.query(last_insert_sql)
            # p last_id

            clear_tabs = db.prepare(@@clear_user_tab_sql)
            clear_feed = db.prepare(@@clear_user_feeds_sql)
            add_tab    = db.prepare(@@add_tab_sql)
            add_feed   = db.prepare(@@add_feed_sql)
           
            clear_tabs.execute user_id

            tab_num = 0
            opts.each { |tab|
                tab_num += 1 
                add_tab.execute user_id, tab_num, tab[:tabname] 
                p tab[:tabname]
                position = 1
                clear_feed.execute user_id, tab_num
                p tab[:tabrss].each{|url|
                    add_feed.execute user_id, tab_num, position, url
                    position = position + 1 
                }
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

    def _process_mysql(f)
        begin
            db = dbconn(@mysql_opts)
            add_article = db.prepare(@@add_article_sql)
            pubdate_timestamp = f['pubdate'].to_i
            add_article.execute f['feed_title'], f['title'], f['summary'], f['url'], pubdate_timestamp
            p "Article added: #{f['title']}"
            rescue Mysql::Error => e
                if e.errno == 1062
                    p("Article already in db: #{f['title']}")
                else
                    $logger.error(e.message)
                    # raise e
                end
        end
    end


    def _process(feed, how_many)
        show_this_many_summaries = how_many # show a summary for every article
        processed_feed = []
        if feed.nil?
            return processed_feed 
        end
        how_many = how_many - 1
        feed.entries[0 .. how_many ].each {|e|

            summary = processed_feed.count < show_this_many_summaries ? (e.summary.nil? ? "" : e.summary)  : ""
            summary = Sanitize.clean(summary, { :attributes => { 'a' => ['href'] }})

            f = { 
                'feed_title' => feed.title,
                'title' => e.title,
                'url'   => e.url,
                'pubdate' => e.published,
                'summary' => summary
            }
            processed_feed << f 
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
            tab[:tabrss].each {|feed|

                res = fetch(feed)
                feed_title = res.nil? ? "untitled" : res.title
                processed_feed = _process(res, process_limit)
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
        return tabs_parse
    end
    
  end # end self class
end # end Mg Module
