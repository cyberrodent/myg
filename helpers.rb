require 'nokogiri'

require 'sinatra/base'

module Mygoogle
    module Helpers

        def parsePrefs
            pref_file = "./data/iGoogle-settings.xml"
            f = File.open(pref_file)
            @doc = Nokogiri::XML(f)
            f.close

            puts "#{@doc.namespaces()}"
            r = @doc.xpath("//pref:ModulePrefs", 
               'pref' => "http://schemas.google.com/GadgetTabML/2008")
          

            # @doc.remove_namespaces
            titles = @doc.xpath("//pref:Tab", 
               'pref' => "http://schemas.google.com/GadgetTabML/2008")

            puts " parrsed doc"
            o = ""
            titles.each {|t| o += "#{t.xpath("@title")} <br>" }
            o
        end
    end
end
