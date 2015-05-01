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
      story = Story.create!(title: @data['title'], url: @data['url'])

      status 201
      headers['Location'] = '/stories'
      { id: story.id, score: story.score }.to_json
    end

    patch '/stories/:id/vote' do
      user = authenticate!
      vote = Vote.find_or_create_by(user_id: user.id, story_id: params['id'])
      vote.value = @data['delta']
      vote.save

      status 200
      { score: Story.find(params['id']).score }.to_json
    end
  end
end
