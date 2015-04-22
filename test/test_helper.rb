ENV['RACK_ENV'] ||= 'test'
require 'database_cleaner'
require 'rack/test'
require 'rack/lint'
require 'minitest/autorun'
require 'api/stories'
require 'api/users'

class ActiveSupport::TestCase
  DatabaseCleaner.strategy = :truncation

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
