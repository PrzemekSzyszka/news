require_relative '../test_helper'

class UsersTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Lint.new(API::Users.new)
  end

  def setup
    super
  end

  def test_creates_a_user
    post '/users', { username: 'Alan', password: 'Ala1Ma2Kota' }.to_json,
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=1' }
    assert_equal 201, last_response.status
  end

  def test_fails_to_create_a_user_without_username
    post '/users', { password: 'Ala1Ma2Kota' }.to_json, { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=1' }
    assert_equal 422, last_response.status

    data = JSON.parse last_response.body
    assert_equal "Validation failed: Username can't be blank", data['error']
  end
end
