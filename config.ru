require './config/environment.rb'
require './lib/api/application'
require './lib/api/v1/stories.rb'
require './lib/api/v1/users.rb'

run API::Application
