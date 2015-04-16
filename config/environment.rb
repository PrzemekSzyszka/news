require 'rake'
require 'dotenv/tasks'
require 'yaml'
require 'active_record'

env = ENV['DATABASE_ENV'] || 'development'
config = YAML.load_file('config/database.yml') [env.to_s]
ActiveRecord::Base.establish_connection config
