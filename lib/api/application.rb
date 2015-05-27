require 'sinatra'
require 'sinatra/respond_with'
require 'sinatra/router'
require 'sinatra/namespace'
require 'sinatra/url_for'
require 'json'
require 'bcrypt'
require './config/environment'
require './lib/models/story'
require './lib/models/user'
require './lib/models/vote'
require './lib/models/board'
require 'dalli'
require 'rack/cache'
require 'kaminari/sinatra'
require 'rack'
require 'rack/contrib'
require 'rack/accept'
require 'i18n'
require 'i18n/backend/fallbacks'
require_relative 'errors'

module API
  class Application < Sinatra::Base
    use Sinatra::Router do
      mount API::Stories
      mount API::Users
    end
  end
end
