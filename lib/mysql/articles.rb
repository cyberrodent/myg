require "mysql"
require "./lib/mysql"
require './lib/mysql/queries'

class Mysqlarticle < Mysqlcore
  def Mysqlarticle.process(f)
    begin
      db = Mysqlcore.dbconn(Mg.mysql_opts)
      add_article = db.prepare(Queries.getq('add_article'))
      pubdate_timestamp = f['pubdate'].to_i

      $logger.info("Adding article #{f['title']}")
      if f['title'] == ""
              f['title'] = "no title"
      end

      add_article.execute f['feed_title'], f['title'], f['summary'], f['url'], pubdate_timestamp, f['id']
      $logger.info "Article added:#{f['id']} #{f['title']}  "
    rescue Mysql::Error => e
      if e.errno == 1062
        $logger.error "Article already in db:#{f['id']} #{f['title']}"
      else
        $logger.error(e.message)
        # raise e
      end
    end

  end
end
