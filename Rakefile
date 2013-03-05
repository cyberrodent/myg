require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
        # t.libs << 'lib'
        t.pattern = 'test/**/*_test.rb'
        t.verbose = false
end



namespace :myg do

  require './lib/mygoogle'

  desc "Prints the name of each tab and a list of the feed urls"  
  task :feedlist do
    xmldoc = Mg.init
    tabs = Mg.read_prefs_xml
    tabs.each {|tab|
        puts tab[:tabname]
        puts "\t"  + tab[:tabrss].join("\n\t")
    }
  end




end # end of namespace :myg
