require_relative 'base'
require_relative '../models/story'

module API
  class Stories < Base

    get '/stories' do
      content_type :json
      Story.all.to_json
    end

    get '/stories/:id' do
      content_type :json
      Story.find(params[:id]).to_json
    end

    post '/stories' do
      story = params[:story]
      story = Story.create!(title: story[:title], url: story[:url])

      status 201
      content_type :json
      { id: story.id }.to_json
    end
  end
end
