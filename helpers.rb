require 'nokogiri'

require 'sinatra/base'

module Mygoogle
    module Helpers

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
    end
end
