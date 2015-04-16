require 'rack/test'
require 'rack/lint'
require 'minitest/autorun'
require 'api/stories'
require 'story'
require 'test_helper'
require 'pry'

class NewsTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Lint.new(API::Stories.new)
  end

  def setup
    super
    Story.create!(id: 1, title: 'Lorem ipsum', url: 'http://www.lipsum.com/')
    Story.create!(id: 2, title: 'Lorem ipsum', url: 'http://www.lipsum.com/')
  end

  def test_app_returns_submitted_stories
    get '/stories'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body

    assert_equal 1, data[0]['id']
    assert_equal 2, data[1]['id']
    assert_equal 'application/json', last_response.content_type
  end

  def test_getting_an_single_story
    get '/stories/1'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body

    assert_equal 1, data['id']
    assert_equal 'Lorem ipsum', data['title']
    assert_equal 'http://www.lipsum.com/', data['url']
    assert_equal "application/json", last_response.content_type
  end

  def test_submitting_a_new_story
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }
    assert_equal 201, last_response.status

    data = JSON.parse last_response.body
    assert data['id'] != nil
  end

  def test_updating_a_story
    skip 'pending'
    put '/stories/1', { id: 1, title: 'Lorem epsum', url: 'http://www.l.com' }
    assert_equal 204, last_response.status
  end

  def test_upvoting_a_story
    skip 'pending'
    patch '/stories/1/vote', { delta: 1 }
    assert_equal 200, last_response.status
  end

  def test_downvoting_a_story
    skip 'pending'
    patch '/stories/1/vote', { delta: -1 }
    assert_equal 200, last_response.status
  end

  def test_undoing_a_vote
    skip 'pending'
    delete '/stories/1/vote'
    assert_equal 204, last_response.status
  end

  def test_creating_a_user
    skip 'pending'
    post '/users', { username: 'Alan', password: 'Ala1Ma2Kota' }
    assert_equal 201, last_response.status
  end

  def test_fetching_not_existing_story
    get '/stories/400'
    assert_equal 404, last_response.status
    data = JSON.parse last_response.body
    assert_equal "Couldn't find Story with 'id'=400", data["error"]
  end
end
