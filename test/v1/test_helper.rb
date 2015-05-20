ENV['RACK_ENV'] ||= 'test'
require 'database_cleaner'
require 'rack/test'
require 'rack/lint'
require 'minitest/autorun'
require 'api/v1/stories'
require 'api/v1/users'

class ActiveSupport::TestCase
  DatabaseCleaner.strategy = :truncation

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
