require './config/environment.rb'
require './lib/api/application'
require './lib/api/v1/stories.rb'
require './lib/api/v1/users.rb'
require './lib/api/v2/stories.rb'
require './lib/api/v2/users.rb'
require './lib/api/legacy/stories.rb'
require './lib/api/legacy/users.rb'

# Defined in ENV on Heroku. To try locally, start memcached and uncomment:
# ENV["MEMCACHE_SERVERS"] = "localhost"
if memcache_servers = ENV["MEMCACHE_SERVERS"]
  use Rack::Cache,
    verbose: true,
    metastore:   "memcached://#{memcache_servers}",
    entitystore: "memcached://#{memcache_servers}"
end

run API::Application
