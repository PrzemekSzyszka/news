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
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 201, last_response.status
  end

  def test_fails_to_create_a_user_without_username
    post '/users', { password: 'Ala1Ma2Kota' }.to_json,
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 422, last_response.status

    data = JSON.parse last_response.body
    assert_equal "Validation failed: Username can't be blank", data['error']
  end

  def test_returns_user_validation_message_in_polish
    I18n.default_locale = :pl
    post '/users', { password: 'Ala1Ma2Kota' }.to_json,
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    data = JSON.parse last_response.body
    assert_equal 'Walidacja zakończona niepowodzeniem: Nazwa użytkownika nie może być pusta', data['error']
    I18n.default_locale = :en
  end

  def test_returns_user_validation_message_depending_on_http_accept_language_header
    post '/users', { password: 'Ala1Ma2Kota' }.to_json,
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2',
                     'HTTP_ACCEPT_LANGUAGE' => 'pl;q=0.9, en;q=0.6' }
    data = JSON.parse last_response.body
    assert_equal 'Walidacja zakończona niepowodzeniem: Nazwa użytkownika nie może być pusta', data['error']
  end

  def test_returns_status_response_using_the_supported_languege_with_highest_q_value
    post '/users', { password: 'Ala1Ma2Kota' }.to_json,
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2',
                     'HTTP_ACCEPT_LANGUAGE' => 'de, pl;q=0.9, en;q=0.6' }
    data = JSON.parse last_response.body
    assert_equal 'Walidacja zakończona niepowodzeniem: Nazwa użytkownika nie może być pusta', data['error']
  end

  def test_returns_status_406_when_no_language_is_not_supported
    post '/users', { password: 'Ala1Ma2Kota' }.to_json,
                   { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2',
                     'HTTP_ACCEPT_LANGUAGE' => 'de' }
    data = JSON.parse last_response.body
    assert_equal 406, last_response.status
    assert_equal 'Not Acceptable', data['error']
  end
end
