require "mysql"
require "./lib/mysql"
require './lib/queries'

class Mysqlarticle < Mysqlcore
  def Mysqlarticle.process(f)
    begin
      db = Mysqlcore.dbconn(Mg.mysql_opts)
      add_article = db.prepare(Queries.getq('add_article'))
      pubdate_timestamp = f['pubdate'].to_i
      add_article.execute f['feed_title'], f['title'], f['summary'], f['url'], pubdate_timestamp
      p "Article added: #{f['title']}"
    rescue Mysql::Error => e
      if e.errno == 1062
        p "Article already in db: #{f['title']}"
      else
        $logger.error(e.message)
        # raise e
      end
    end

  end
end
