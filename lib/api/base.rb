require 'sinatra'
require 'json'
require './config/environment'
require './lib/models/story'
require './lib/models/user'
require './lib/models/vote'

module API
  class Base < Sinatra::Base
    set :show_exceptions => false

    configure do
      use ActiveRecord::ConnectionAdapters::ConnectionManagement
    end

    before do
      body = request.body.read.to_s
      data = JSON.parse body if body.present?
      @data = JSON.parse body if body.present?
    end

    after do
      content_type :json
    end

    error ActiveRecord::RecordNotFound do
      status 404

      error_message
    end

    error ActiveRecord::RecordInvalid do
      status 422

      error_message
    end

    helpers do
      def authenticate!
        return user if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, { error: 'Not authorized' }.to_json
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and user_found?(@auth.credentials)
      end
    end

    private

    def error_message
      e = env['sinatra.error']
      { error: e.message }.to_json
    end

    def user_found?(credentials)
      User.where(username: credentials[0], password: credentials[1]).present?
    end

    def user
      User.where(username: @auth.credentials[0], password: @auth.credentials[1]).first
    end
  end
end
