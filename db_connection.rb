require 'sequel'
require 'logger'

class DBConnection
  @db = nil 
  @params = nil

  class <<self
    def connect
      init
      return @db
    end

    def get_db_name
      init
      return @params[:database]
    end

    def load_config
      config_file = './config/database.yml'
      if File.exist?(config_file)
        @params = YAML.load(File.open(config_file))

        new_params = {}
        @params.each {|k,v| new_params[k.to_sym] = v.to_s}
        @db = Sequel.mysql(new_params) if @db.nil?
        @db.loggers << Logger.new("./log/db.log")
      end 
    end

    def init
      load_config if @db.nil?
    end
  end
end
