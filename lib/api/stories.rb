require_relative 'base'

module API
  class Stories < Base

    get '/stories' do
      Story.all.to_json
    end

    get '/stories/:id' do
      Story.find(params['id']).to_json
    end

    post '/stories' do
      authenticate!
      story = Story.create!(title: @data['title'], url: @data['url'], user_id: @data['user_id'])

      status 201
      headers['Location'] = '/stories'
      { id: story.id, score: story.score }.to_json
    end

    put '/stories/:id' do |id|
      user = authenticate!

      if story = user.stories.find_by(id: id)
        story.update(@data)

        status 204
        headers['Location'] = '/stories'
        { id: story.id, score: story.score }.to_json
      else
        raise_forbidden_action_error
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
  end
end
