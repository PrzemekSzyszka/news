require_relative 'test_helper'

class StoriesTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Lint.new(API::Stories.new)
  end

  def setup
    super
    @username = 'Ziom'
    @password = 'password'
    user = User.create!(username: @username, password_hash: @password)
    Story.create!(id: 1, title: 'Lorem ipsum', url: 'http://www.lipsum.com/')
    Story.create!(id: 2, title: 'Lorem ipsum', url: 'http://www.lipsum.com/')
  end

  def test_app_returns_submitted_stories
    get '/stories'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body

    assert_equal 1, data[0]['id']
    assert_equal 2, data[1]['id']
    assert_equal 0, data[0]['score']
    assert_equal 0, data[1]['score']
    assert_equal 'application/json', last_response.content_type
  end

  def test_getting_an_single_story
    get '/stories/1'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body

    assert_equal 1, data['id']
    assert_equal 0, data['score']
    assert_equal 'Lorem ipsum', data['title']
    assert_equal 'http://www.lipsum.com/', data['url']
    assert_equal 'application/json', last_response.content_type
  end

  def test_submitting_a_new_story
    authorize @username, @password
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }.to_json,
                     { "CONTENT_TYPE" => "application/json" }
    assert_equal 201, last_response.status

    assert_equal '/stories', last_response.original_headers['Location']
    data = JSON.parse last_response.body
    assert data['id'] != nil
  end

  def test_submitting_new_story_fails_when_title_is_missing
    authorize @username, @password
    post '/stories', { url: 'http://www.lorem.com' }.to_json,
                     { "CONTENT_TYPE" => "application/json" }
    assert_equal 422, last_response.status

    data = JSON.parse last_response.body
    assert_equal "Validation failed: Title can't be blank", data['error']
  end

  def test_unauthorized_user_fails_to_submit_story
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }.to_json,
                     { "CONTENT_TYPE" => "application/json" }
    assert_equal 401, last_response.status

    data = JSON.parse last_response.body
    assert_equal 'Not authorized', data['error']
  end

  def test_updating_a_story
    skip 'pending'
    put '/stories/1', { id: 1, title: 'Lorem epsum', url: 'http://www.l.com' }.to_json,
                      { "CONTENT_TYPE" => "application/json" }
    assert_equal 204, last_response.status
  end

  def test_upvoting_a_story
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body
    assert_equal 1, data['score']
  end

  def test_second_upvoting_doesnt_affect_story
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    data = JSON.parse last_response.body
    assert_equal 1, data['score']
  end

  def test_downvoting_a_story
    skip 'pending'
    patch '/stories/1/vote', { delta: -1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    assert_equal 200, last_response.status
  end

  def test_undoing_a_vote
    skip 'pending'
    delete '/stories/1/vote'
    assert_equal 204, last_response.status
  end

  def test_fetching_not_existing_story
    get '/stories/400'
    assert_equal 404, last_response.status
    data = JSON.parse last_response.body
    assert_equal "Couldn't find Story with 'id'=400", data["error"]
  end
end
