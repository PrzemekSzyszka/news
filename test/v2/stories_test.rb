require_relative '../test_helper'

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
    @board = Board.create(name: "Example board")
    user   = User.create!(username: @username, password_hash: @password)
    User.create!(username: @second_username, password_hash: @password)
    @story1 = Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com/', user: user, board: @board)
    @story2 = Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com/', user: user, board: @board)
  end

  def test_app_redirects_to_v1_when_no_version_specified
    get '/stories'
    assert_equal 301, last_response.status
    assert_equal 'Moved permanently', last_response.body
  end

  def test_app_returns_submitted_stories
    header 'Accept', 'version=2'
    get '/stories'
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body

    assert_equal @story1.id, data[0]['id']
    assert_equal @story2.id, data[1]['id']
    assert_equal 0, data[0]['score']
    assert_equal 0, data[1]['score']
    assert_equal 'application/json', last_response.content_type
  end

  def test_returns_all_stories_in_xml_format
    header 'Accept', 'application/xml; version=2'

    get '/stories'
    assert_equal [@story1, @story2].to_xml, last_response.body
  end

  def test_returns_all_stories_in_format_with_higher_q
    header 'Accept', 'application/xml;q=0.4 application/json;q=0.8; version=2'

    get '/stories'
    assert_equal [@story1, @story2].to_json, last_response.body
  end

  def test_getting_an_single_story
    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"
    assert_equal 200, last_response.status
    data = JSON.parse last_response.body

    assert_equal @story1.id, data['id']
    assert_equal 0, data['score']
    assert_equal 'Lorem ipsum', data['title']
    assert_equal 'http://www.lipsum.com/', data['url']
    assert_equal 'application/json', last_response.content_type
  end

  def test_submitting_a_new_story
    authorize @username, @password
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }.to_json,
                     { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 201, last_response.status

    assert_equal '/v2/stories', last_response.original_headers['Location']
    data = JSON.parse last_response.body
    assert data['id'] != nil
  end

  def test_submitting_new_story_in_xml_format
    authorize @username, @password
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }.to_xml,
                        { 'CONTENT_TYPE' => 'application/xml', 'HTTP_ACCEPT' => 'application/xml; version=2' }
    assert_equal 201, last_response.status
  end

  def test_submitting_new_story_fails_when_title_is_missing
    authorize @username, @password
    post '/stories', { url: 'http://www.lorem.com' }.to_json,
                     { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 422, last_response.status

    data = JSON.parse last_response.body
    assert_equal "Validation failed: Title can't be blank", data['error']
  end

  def test_unauthorized_user_fails_to_submit_story
    post '/stories', { title: 'Lorem epsum', url: 'http://www.lorem.com' }.to_json,
                     { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 401, last_response.status

    data = JSON.parse last_response.body
    assert_equal 'Unauthorized', data['error']
  end

  def test_updating_a_story
    authorize @username, @password
    put "/stories/#{@story1.id}", { id: @story1.id, url: 'http://www.l.com' }.to_json,
                                  { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 204, last_response.status

    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"
    data = JSON.parse last_response.body
    assert_equal 'http://www.l.com', data['url']
  end

  def test_updating_story_fails_for_not_authorized_user
    authorize @second_username, @password
    put "/stories/#{@story1.id}", { id: @story1.id, url: 'http://www.l.com' }.to_json,
                                  { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    assert_equal 403, last_response.status
  end

  def test_upvoting_a_story
    authorize @username, @password
    patch '/stories/1/vote', { delta: 1 }.to_json, { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }

    assert_equal 204, last_response.status
    assert_equal '', last_response.body
  end

  def test_second_upvoting_doesnt_affect_story
    authorize @username, @password
    patch "/stories/#{@story1.id}/vote", { delta: 1 }.to_json, { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    header 'Accept', 'version=2'
    patch "/stories/#{@story1.id}/vote", { delta: 1 }.to_json, { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"

    data = JSON.parse last_response.body
    assert_equal 1, data['score']
  end

  def test_downvoting_a_story
    authorize @username, @password
    patch "/stories/#{@story1.id}/vote", { delta: -1 }.to_json,
                                         { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }

    assert_equal 204, last_response.status
    assert_equal '', last_response.body
  end

  def test_user_downvotes_a_story_upvoted_previously
    authorize @username, @password
    patch "/stories/#{@story1.id}/vote", { delta: 1 }.to_json,
                                         { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"
    data = JSON.parse last_response.body
    assert_equal 1, data['score']

    patch "/stories/#{@story1.id}/vote", { delta: -1 }.to_json,
                                         { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"
    data = JSON.parse last_response.body
    assert_equal -1, data['score']
  end

  def test_undoing_a_vote
    authorize @username, @password
    patch "/stories/#{@story1.id}/vote", { delta: 1 }.to_json,
                                         { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"
    data = JSON.parse last_response.body
    assert_equal 1, data['score']

    header 'Accept', 'version=2'
    delete "/stories/#{@story1.id}/vote"
    assert_equal 204, last_response.status
    assert_equal '', last_response.body

    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}"
    data = JSON.parse last_response.body
    assert_equal 0, data['score']
  end

  def test_fetching_not_existing_story
    header 'Accept', 'version=2'
    get '/stories/400'
    assert_equal 404, last_response.status
    data = JSON.parse last_response.body
    assert_equal "Couldn't find Story with 'id'=400", data['error']
  end

  def test_redirects_user_to_story_url
    header 'Accept', 'version=2'
    get "/stories/#{@story1.id}/url"
    assert_equal 302, last_response.status
    assert_equal "http://www.lipsum.com/", last_response.location
  end

  def test_user_deletes_a_story
    authorize @username, @password
    header 'Accept', 'version=2'
    delete "/stories/#{@story1.id}"
    assert_equal 204, last_response.status
  end

  def test_user_fails_to_delete_other_user_story
    authorize @second_username, @password
    header 'Accept', 'version=2'
    delete "/stories/#{@story1.id}"
    assert_equal 404, last_response.status
  end

  def test_recent_endpoint_returns_10_stories_sorted_by_updated_at
    prepare_stories
    header 'Accept', 'version=2'
    get '/recent'
    data = JSON.parse last_response.body
    assert_equal 10, data.count
    assert_operator data[0]['updated_at'], :<, data[1]['updated_at']
  end

  def test_stories_endpoint_returns_10_stories_sorted_by_votes
    prepare_stories
    header 'Accept', 'version=2'
    get '/stories'
    data = JSON.parse last_response.body
    assert_equal 10, data.count
    assert_operator data[0]['score'], :>, data[1]['score']
  end

  def test_recent_endpoint_has_set_cache_control_header
    header 'Accept', 'version=2'
    get '/recent'
    assert_equal 'public, max-age=30', last_response.headers['Cache-Control']
  end

  def test_stories_endpoint_responds_with_304_if_board_wasnt_updated
    header 'Accept', 'version=2'
    get '/stories'
    assert_equal @board.updated_at.httpdate, last_response.headers['Last-modified']
    header 'Accept', 'version=2'
    header 'If-Modified-Since', last_response.headers['Last-modified']
    get '/stories'
    assert_equal 304, last_response.status
  end

  def test_stories_endpoint_responds_with_different_last_modified_header_after_updating_story
    header 'Accept', 'version=2'
    get '/stories'

    updated_at = @board.updated_at.httpdate
    assert_equal updated_at, last_response.headers['Last-modified']

    sleep 1

    authorize @username, @password
    put "/stories/#{@story1.id}", { id: @story1.id, url: 'http://www.l.com' }.to_json,
                                  { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'version=2' }
    header 'Accept', 'version=2'
    header 'If-Modified-Since', updated_at
    get '/stories'
    assert_operator updated_at, :<, last_response.headers['Last-modified']
  end

  def test_recent_stories_endpoint_has_next_page_in_link_header
    prepare_stories
    header 'Accept', 'version=2'
    get '/recent'

    assert_equal "<http://example.org/v2/recent&per_page=10&page=2>; rel='next'", last_response.headers['Link']
  end

  def test_recent_stories_endpoint_has_next_page_and_last_page_set_in_link_header
    prepare_stories
    header 'Accept', 'version=2'
    get '/recent', { per_page: 4 }

    assert_equal "<http://example.org/v2/recent&per_page=4&page=2>; rel='next', "\
                 "<http://example.org/v2/recent&per_page=4&page=3>; rel='last'", last_response.headers['Link']
  end

  def test_recent_stories_endpoint_has_all_navigation_links_in_link_header
    prepare_stories
    header 'Accept', 'version=2'
    get '/recent', { per_page: 2, page: 3 }

    assert_equal "<http://example.org/v2/recent&per_page=2&page=4>; rel='next', "\
                 "<http://example.org/v2/recent&per_page=2&page=6>; rel='last', "\
                 "<http://example.org/v2/recent&per_page=2&page=2>; rel='prev', "\
                 "<http://example.org/v2/recent&per_page=2&page=1>; rel='first'", last_response.headers['Link']
  end
end
