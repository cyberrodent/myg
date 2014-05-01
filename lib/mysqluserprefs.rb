

require './lib/mysql'
require './lib/userprefs'
require './lib/queries'

class Mysqluserprefs < Mysqlcore

  include Userprefs

  def Mysqluserprefs.get_user_tabs(user_id)
        begin
            res = []
            db = self.dbconn(Mg.mysql_opts)
            user_id = user_id || 1
            get_user = db.prepare(Queries.getq('get_tabs'))
            get_user.execute user_id
            while row = get_user.fetch do
                res << row[0]
            end
        end
        res
  end


  def Mysqluserprefs.get_user_tab(user_id, tab_id)
    begin
      res = []
      db = self.dbconn(Mg.mysql_opts)

      get_user = db.prepare(Queries.getq('get_user_tab'))
      get_user.execute user_id || 1, tab_id

      while row = get_user.fetch do
        res << row
      end
    end
    res

  end

  def Mysqluserprefs.get_prefs(user_id = 1)
    begin
      res = []
      db = self.dbconn(Mg.mysql_opts)
      get_user = db.prepare(Queries.getq('get_user'))
      get_user.execute user_id
      last_tab = ""
      idx = -1
      while row = get_user.fetch do
        if row[0] != last_tab
          idx = idx + 1
          obj = {
            :tabname => row[0],
            :tab_id => row[3],
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

  def Mysqluserprefs.set_feed_name(user_id, tab_id, position, feed_name)
    begin
      user_id = user_id || 1
      db = self.dbconn(Mg.mysql_opts)
      sth = db.prepare(Queries.getq('set_feed_title_on_feed'))
      sth.execute feed_name, user_id, tab_id, position
      puts(feed_name, user_id, tab_id, position)
    end

  end

  # given the right input
  # store the user's preferences into the mysql backend
  # returns indicator of success tbd
  def Mysqluserprefs.store_user_prefs(user_id, opts)

    begin
      db = self.dbconn(Mg.mysql_opts)

      user_id = user_id || 100

      clear_tabs = db.prepare(Queries.getq('clear_user_tab'))
      clear_feed = db.prepare(Queries.getq('clear_user_feeds'))
      add_tab    = db.prepare(Queries.getq('add_tab'))
      add_feed   = db.prepare(Queries.getq('add_feed'))

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

  def Mysqluserprefs.add_feed(user_id, tab_num, position, url)
    begin
      db = self.dbconn(Mg.mysql_opts)
      user_id = user_id || 100
      add_feed   = db.prepare(Queries.getq('add_feed'))
      add_feed.execute user_id, tab_num, position, url
    ensure
      db.close
    end
  end

end
