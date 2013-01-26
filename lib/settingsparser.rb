require 'nokogiri'


require 'sinatra/base'

module Sinatra
    module Perfparser
        def parse
            pref_file = "./data/iGoogle-settings.xml"
            f = File.open(pref_file)
            doc = Nokogiri::XML(f)
            f.close
            doc
        end
    end
    helpers Perfparser
end

