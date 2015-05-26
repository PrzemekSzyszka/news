require 'sinatra'
require 'sinatra/respond_with'
require 'sinatra/router'
require "sinatra/namespace"
require 'json'
require 'bcrypt'
require './config/environment'
require './lib/models/story'
require './lib/models/user'
require './lib/models/vote'
require './lib/models/board'
require "dalli"
require 'rack/cache'
require_relative 'errors'

module API
  class Application < Sinatra::Base
    use Sinatra::Router do
      mount API::Stories
      mount API::Users
    end
  end
end
