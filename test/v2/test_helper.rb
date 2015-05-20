ENV['RACK_ENV'] ||= 'test'
require 'database_cleaner'
require 'rack/test'
require 'rack/lint'
require 'minitest/autorun'
require 'api/v2/stories'
require 'api/v2/users'
require 'api/legacy/stories'
require 'api/legacy/users'

class ActiveSupport::TestCase
  DatabaseCleaner.strategy = :truncation

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
