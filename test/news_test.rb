require 'rubygems'
require 'rack/test'
require 'minitest/autorun'
require_relative '../lib/news.rb'
require 'rack/lint'

class NewsTest < Minitest::Test
  include Rack::Test::Methods

  def app
    News.new
  end

  def test_app_returns_an_response
    get "/"
    assert_equal "Hello News!", last_response.body
  end
end
