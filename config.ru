require './config/environment.rb'
require './lib/api/application'
require './lib/api/v1/stories.rb'
require './lib/api/v1/users.rb'
require './lib/api/v2/stories.rb'
require './lib/api/v2/users.rb'

run API::Application
