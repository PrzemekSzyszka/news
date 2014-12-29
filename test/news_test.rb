require 'rubygems'
require 'rack/test'
require 'minitest/autorun'
require 'api/stories'
require 'rack/lint'
require 'story'
require 'test_helper'

class NewsTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rack::Lint.new(API::Stories.new)
  end

  def setup
    Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com/')
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
    put '/stories/#{story.id}', 'some data'
    assert_equal 204, last_response.status
  end

  def test_upvoting_a_story
    skip 'pending'
    patch '/stories/#{story.id}/vote', 'some data'
    assert_equal 200, last_response.status
  end

  def test_downvoting_a_story
    skip 'pending'
    patch '/stories/#{story.id}vote', 'some data'
    assert_equal 200, last_response.status
  end

  def test_undoing_a_vote
    skip 'pending'
    delete '/stories/#{story.id}/vote'
    assert_equal 204, last_response.status
  end

  def test_creating_a_user
    skip 'pending'
    post '/users', 'some data'
    assert_equal 201, last_response.status
  end
end
