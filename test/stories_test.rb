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
    @second_username = 'Czesio'
    user = User.create!(id: 1, username: @username, password_hash: @password)
    User.create!(id: 2, username: @second_username, password_hash: @password)
    @story1 = Story.create!(id: 1, title: 'Lorem ipsum', url: 'http://www.lipsum.com/', user: user)
    @story2 = Story.create!(id: 2, title: 'Lorem ipsum', url: 'http://www.lipsum.com/', user: user)
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

  def test_returns_all_stories_in_xml_format
    header 'Accept', 'application/xml'

    get '/stories'
    assert_equal [@story1, @story2].to_xml, last_response.body
  end

  def test_returns_all_stories_in_format_with_higher_q
    header 'Accept', 'application/xml;q=0.4 application/json;q=0.8'

    get '/stories'
    assert_equal [@story1, @story2].to_json, last_response.body
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

  def test_submitting_new_story_in_xml_format
    authorize @username, @password
    header 'Accept', 'application/xml'
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }.to_xml,
                     { "CONTENT_TYPE" => "application/xml" }
    assert_equal 201, last_response.status
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
    assert_equal 'Not authenticated', data['error']
  end

  def test_updating_a_story
    authorize @username, @password
    put '/stories/1', { id: 1, url: 'http://www.l.com' }.to_json,
                      { "CONTENT_TYPE" => "application/json" }
    assert_equal 204, last_response.status

    get '/stories/1'
    data = JSON.parse last_response.body
    assert_equal 'http://www.l.com', data['url']
  end

  def test_updating_story_fails_for_not_authorized_user
    authorize @second_username, @password
    put '/stories/1', { id: 1, url: 'http://www.l.com' }.to_json,
                      { "CONTENT_TYPE" => "application/json" }
    assert_equal 403, last_response.status
  end

  def test_upvoting_a_story
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }

    assert_equal 204, last_response.status
    assert_equal '', last_response.body
  end

  def test_second_upvoting_doesnt_affect_story
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    get '/stories/1'

    data = JSON.parse last_response.body
    assert_equal 1, data['score']
  end

  def test_downvoting_a_story
    authorize @username, @password
    patch '/stories/1/vote', { delta: -1 }.to_json, { "CONTENT_TYPE" => "application/json" }

    assert_equal 204, last_response.status
    assert_equal '', last_response.body
  end

  def test_user_downvotes_a_story_upvoted_previously
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    get '/stories/1'
    data = JSON.parse last_response.body
    assert_equal 1, data['score']

    patch '/stories/1/vote', { delta: -1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    get '/stories/1'
    data = JSON.parse last_response.body
    assert_equal -1, data['score']
  end

  def test_undoing_a_vote
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { "CONTENT_TYPE" => "application/json" }
    get '/stories/1'
    data = JSON.parse last_response.body
    assert_equal 1, data['score']

    delete '/stories/1/vote'
    assert_equal 204, last_response.status
    assert_equal '', last_response.body

    get '/stories/1'
    data = JSON.parse last_response.body
    assert_equal 0, data['score']
  end

  def test_fetching_not_existing_story
    get '/stories/400'
    assert_equal 404, last_response.status
    data = JSON.parse last_response.body
    assert_equal "Couldn't find Story with 'id'=400", data["error"]
  end

  def test_redirects_user_to_story_url
    get '/stories/1/url'
    assert_equal 302, last_response.status
    assert_equal "http://www.lipsum.com/", last_response.location
  end
end
