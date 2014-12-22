require 'sinatra'

class News < Sinatra::Base
  def call(env)
    [200, {"Content-Type" => "text/html"}, "Hello News!"]
  end

  get '/' do
    "Hello World"
  end
end
