require 'sinatra'
require 'json'

class Api < Sinatra::Base
  get '/' do
    'Hello News!'
  end

  get '/stories' do
    content_type :json
    [
      {
        id: 1,
        title: 'title1',
        url: 'http://www.lipton1.com'
      },
      {
        id: 2,
        title: 'title2',
        url: 'http://www.lipton2.com'
      }
    ].to_json
  end

  get '/stories/:id' do
    content_type :json
    {
      id: params[:id],
      title: 'title',
      url: 'http://www.lipton.com'
    }.to_json
  end
end
