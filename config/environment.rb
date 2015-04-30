require 'yaml'
require 'dotenv'
require 'active_record'

Dotenv.load
env = ENV['DATABASE_ENV'] || 'development'
config = YAML.load_file('config/database.yml')[env]
ActiveRecord::Base.establish_connection config
