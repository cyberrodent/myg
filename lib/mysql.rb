require "mysql"

class Mysqlcore
    def Mysqlcore.dbconn(opts)
        begin
            db = Mysql.new(opts[:host], opts[:user], opts[:pass], opts[:dbname]);
            db.options(Mysql::SET_CHARSET_NAME, 'utf8')
            db.query("SET NAMES utf8")
        rescue Mysql::Error
            p("Can't connect to this database: #{opts[:host]}")
            db = nil
        end
        db
    end

end
