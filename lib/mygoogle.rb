
require 'nokogiri'
require 'json'
require 'feedzirra'

# Mg is a module to collect stuff for the MyGoogle web app
module Mg


  @pref_file = "./data/iGoogle-settings.xml"
  @doc = nil

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
