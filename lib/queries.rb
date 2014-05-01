module Queries
  #
  # SQL Queries for mygoogle
  #
  @@sqlq = {} # our queries

  def Queries.getq(key)
    @@sqlq[key]
  end

  # SQL QUERIES users TABLE
  @@sqlq['make_user'] = "INSERT INTO users (`user_name`) VALUES ('jkolber')"

  # SQL QUERIES user_tab TABLE
  @@sqlq['add_tab']        = "INSERT INTO `user_tab` (user_id, tab_id, tab_name)
    VALUES (?, ?, ?)"
  @@sqlq['clear_user_tab'] = "DELETE FROM `user_tab`
    WHERE user_id=?"
  @@sqlq['get_tabs']       = "SELECT user_id, tab_id, tab_name
    FROM user_tab
    WHERE user_id = ?
    ORDER BY tab_id"

  # SQL QUERIES feeds TABLE

  @@sqlq['clear_user_feeds'] = "DELETE FROM `feeds`
    WHERE user_id=? AND tab_id=?"
  @@sqlq['add_feed'] =         "INSERT INTO `feeds`
    (`user_id`, `tab_id`, `position`, `url`)
    VALUES (?, ?, ?, ?)"

  # SQL QUERIES articles TABLE
  @@sqlq['add_article'] = "INSERT INTO `article` (`feed_name`, `title`, `summary`, `url`, `pubdate_timestamp`, `article_hash`) VALUES (?, ?, ?, ?, ?, ?)"

  # SQL QUERIES GENERAL
  @@sqlq['feed_report'] = "SELECT a.*, b.tab_name
    FROM feeds a, user_tab b
    WHERE a.tab_id=b.tab_id AND a.user_id = b.user_id"

  @@sqlq['get_user'] = "SELECT b.tab_name , a.position, a.url, b.tab_id
    FROM feeds a, user_tab b
    WHERE a.tab_id=b.tab_id
    AND a.user_id = b.user_id AND a.user_id=?
    AND a.is_active = 1
    ORDER BY a.tab_id, a.position"



  @@sqlq['get_user_tab'] = "SELECT b.tab_name , a.position, a.url
    FROM feeds a, user_tab b
    WHERE a.tab_id=b.tab_id
    AND a.user_id = b.user_id
    AND a.user_id=?
    AND a.tab_id=?
    AND a.is_active = 1
    ORDER BY a.tab_id, a.position"

  @@sqlq['set_tab_id_on_article'] = "";

  @@sqlq['set_feed_title_on_feed'] = "UPDATE feeds
    SET feed_name = ?
    WHERE user_id = ?
    AND tab_id = ?
    AND position = ?"

end
