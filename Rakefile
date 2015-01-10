require 'rubygems'
require 'bundler'
Bundler.setup

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
    # t.libs << 'lib'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
end



namespace :myg do

  require './lib/libraries'
  require './lib/mygoogle'

  desc "Prints the name of each tab and a list of the feed urls"  
  task :feedlist do
    tabs = Mg.get_prefs
    tabs.each {|tab|
        puts tab[:tabname]
        puts "\t"  + tab[:tabrss].join("\n\t")
    }
  end

  desc "fetches a tab or all tabs"
  task :fetch do
      fake_user_id = 1
      tabs = Mg.get_prefs fake_user_id
      parsed = Mg.process(tabs, "tech")
      parsed.each{ |d|
        name = d[:tab_name]
        data = d[:tab_data]
      }
  end

  desc "test out new functions"
    task :it do
      Mg.test
    end

    task :smoke_store_user_prefs do
      opts = [
        { :tabname => "test tab 1",
          :tabrss => [ "url1", "url2" ]
        },
        { :tabname => "test tab 2",
          :tabrss => [ "url3", "url4" ]
        }
      ]
      p Mg.mysql_store_user_prefs(7, opts)
    end

    task :smoke_get_prefs do
      p Mg.get_prefs(1)
    end

    task :smoke_set_feed_name do
      Mg.mysql_set_feed_name(2,2,"Philosophy Forums")
    end

    task :smoke_get_user_tab do
      Mg.mysql_get_user_tab(1)
    end
    task :smoke_get_user_tabs do
        Mg.mysql_get_user_tabs
    end
end # end of namespace :myg
