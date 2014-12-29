require_relative 'base'

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
  end
end
