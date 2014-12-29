require 'sinatra'
require 'json'
require 'active_record'
require 'yaml'

class Base < Sinatra::Base
  configure do
    config = YAML.load_file('config/database.yml') [environment.to_s]
    ActiveRecord::Base.establish_connection config
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
  end
end
