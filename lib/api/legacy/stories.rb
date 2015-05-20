require_relative '../base'

module API
  class Stories < Base
    get '/stories' do
      redirect '/v1/stories', 301, 'Moved permanently'
    end

    get '/stories/:id' do
      redirect '/stories/:id', 301, 'Moved permanently'
    end

    post '/stories' do
      redirect '/stories', 301, 'Moved permanently'
    end

    put '/stories/:id' do
      redirect '/v1/stories/:id', 301, 'Moved permanently'
    end

    patch '/stories/:id/vote' do
      redirect '/v1/stories/:id/vote', 301, 'Moved permanently'
    end

    delete '/stories/:id/vote' do
      redirect '/v1/stories/:id/vote', 301, 'Moved permanently'
    end
  end
end
