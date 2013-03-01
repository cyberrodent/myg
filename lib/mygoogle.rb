require 'nokogiri'

# Mg is a module to collect stuff for the MyGoogle web app
module Mg

  @p = "hi there"
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
            :tabname =>  t['title'],
            :tabrss  => temp_tab 
          }
        end
      }
      myprefs
    end

  end
end
