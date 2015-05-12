require 'yaml'
require 'erb'
require 'dotenv'
require 'active_record'

Dotenv.load
env = ENV['RACK_ENV'] || 'development'
config = YAML.load(ERB.new(File.read(File.join("config","database.yml"))).result)[env]
ActiveRecord::Base.establish_connection config
