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
    assert_equal 200, last_response.status
    assert_equal "Hello News!", last_response.body
  end

  def test_app_returns_submitted_stories
    skip 'pending'
    get '/stories'
    assert_equal 200, last_response.status
  end

  def test_getting_an_single_story
    skip 'pending'
    get '/stories/1'
    assert_equal 200, last_response.status
  end

  def test_submitting_a_new_story
    skip 'pending'
    post '/stories'
    assert_equal 201, last_response.status
  end

  def test_updating_a_story
    skip 'pending'
    put '/stories/1', 'some data'
    assert_equal 204, last_response.status
  end

  def test_upvoting_a_story
    skip 'pending'
    put '/stories/upvote', 'some data'
    assert_equal 200, last_response.status
  end

  def test_downvoting_a_story
    skip 'pending'
    put '/stories/downvote', 'some data'
    assert_equal 200, last_response.status
  end

  def test_undoing_a_vote
    skip 'pending'
    put '/stories/undo', 'some data'
    assert_equal 204, last_response.status
  end

  def test_creating_a_user
    skip 'pending'
    post '/users', 'some data'
    assert_equal 201, last_response.status
  end
end
