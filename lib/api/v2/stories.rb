require_relative '../base'

module API
  class Stories < Base
    namespace '/v2' do
      get '/stories' do
        popular_stories = Story.popular
        last_modified(popular_stories.first.board.updated_at)
        respond_with popular_stories
      end

      get '/recent' do
        respond_with Story.recent
      end

      get '/stories/:id' do |id|
        respond_with Story.find(id)
      end

      get '/stories/:id/url' do |id|
        redirect Story.find(id).url, 302
      end

      post '/stories' do
        user = authenticate!
        board = Board.first
        board = Board.create!(name: "example") if board.nil?
        story = Story.create!(title: @data['title'], url: @data['url'], user_id: user.id, board: board)

        status 201
        headers['Location'] = '/v2/stories'
        respond_with(id: story.id, score: story.score)
      end

      put '/stories/:id' do |id|
        user = authenticate!

        if story = user.stories.find_by(id: id)
          story.update(@data)

          status 204
          headers['Location'] = '/v2/stories'
          respond_with(id: story.id, score: story.score)
        else
          raise AuthorizationError
        end
      end

      patch '/stories/:id/vote' do
        user = authenticate!
        vote = Vote.find_or_create_by(user_id: user.id, story_id: params['id'])
        vote.value = @data['delta']
        vote.save

        status 204
      end

      delete '/stories/:id/vote' do |id|
        user = authenticate!
        vote = Vote.find_by(user_id: user.id, story_id: id)
        Vote.delete(vote) if vote

        status 204
      end

      delete '/stories/:id' do |id|
        user = authenticate!
        Story.destroy(id) if user.stories.find(id)
        status 204
      end
    end
  end
end
