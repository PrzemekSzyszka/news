ENV['RAILS_ENV'] ||= 'test'
require 'rubygems'
require 'rack/test'
require 'minitest/autorun'
require 'api.rb'
require 'rack/lint'
require 'json'
require 'story.rb'

class NewsTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rack::Lint.new(Api.new)
  end

  def setup
    Story.create!(id: 1, title: 'Lorem ipsum', url: 'http://www.lipsum.com/')
  end

  def test_app_returns_an_response
    get "/"
    assert_equal 200, last_response.status
    assert_equal "Hello News!", last_response.body
  end

  def test_app_returns_submitted_stories
    get '/stories'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body
    assert_equal [
          {
            'id' => 1,
            'title' =>'title1',
            'url' => 'http://www.lipton1.com'
          },
          {
            'id' => 2,
            'title' => 'title2',
            'url' => 'http://www.lipton2.com'
          }
        ], data
    assert_equal 'application/json', last_response.content_type
  end

  def test_getting_an_single_story
    get '/stories/1'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body
    assert_equal ({
        'id' => '1',
        'title' => 'title',
        'url' => 'http://www.lipton.com'
      }), data
    assert_equal "application/json", last_response.content_type
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
