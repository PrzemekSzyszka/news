ENV['RACK_ENV'] ||= 'test'
require 'database_cleaner'
require 'rack/test'
require 'rack/lint'
require 'minitest/autorun'
require 'api/v1/stories'
require 'api/v1/users'
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

  def prepare_stories
    users = []
    board = Board.create(name: "Test board")
    10.times do |i|
      users << User.create(username: "User#{i}", password_hash: "password")
      story = Story.create(user: users[0], title: "Scala.js no longer experimental #{i}", board: board,
                           url: "http://scala-lang.org/news/2015/02/05/scala-js-no-longer-experimental.html")
      i.times do |index|
        Vote.create(user: users[index], story: story, value: 1)
      end
    end
  end
end
