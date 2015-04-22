require_relative 'test_helper'

class UsersTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Lint.new(API::Users.new)
  end

  def setup
    super
  end

  def test_creating_a_user
    post '/users', { username: 'Alan', password: 'Ala1Ma2Kota' }
    assert_equal 201, last_response.status
  end
end
