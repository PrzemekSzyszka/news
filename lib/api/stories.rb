require_relative 'base'

module API
  class Stories < Base

    get '/stories' do
      respond_with Story.all
    end

    get '/stories/:id' do |id|
      respond_with Story.find(id)
    end

    get '/stories/:id/url' do |id|
      redirect Story.find(id).url, 302
    end

    post '/stories' do
      user = authenticate!
      story = Story.create!(title: @data['title'], url: @data['url'], user_id: user.id)

      status 201
      headers['Location'] = '/stories'
      respond_with(id: story.id, score: story.score)
    end

    put '/stories/:id' do |id|
      user = authenticate!

      if story = user.stories.find_by(id: id)
        story.update(@data)

        status 204
        headers['Location'] = '/stories'
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
  end
end
