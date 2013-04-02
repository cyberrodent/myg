require 'rubygems'
require 'bundler'
Bundler.setup

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
    tabs = Mg.mysql_get_prefs
    tabs.each {|tab|
        puts tab[:tabname]
        puts "\t"  + tab[:tabrss].join("\n\t")
    }
  end

  desc "fetches a tab or all tabs"
  task :fetch do
      tabs = Mg.mysql_get_prefs
      parsed = Mg.process(tabs, "tech")
      parsed.each{ |d|
        name = d[:tab_name]
        data = d[:tab_data]
      }
  end

  desc "test out new functions"
    task :it do
        tabs = Mg.mysql_get_prefs
        # r = Mg.mysql_store_user_prefs(tabs)
        r = Mg.mysql_get_prefs
        # p r.inspect
    end
end # end of namespace :myg
