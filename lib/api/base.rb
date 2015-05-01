require 'sinatra'
require 'json'
require 'bcrypt'
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
        user = authorize
        return user if user.present?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, { error: 'Not authorized' }.to_json
      end

      def authorize
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        if @auth.provided? && @auth.basic? && @auth.credentials
          user = User.find_by(username: @auth.credentials[0])
          user.password == @auth.credentials[1] ? user : nil
        end
      end
    end

    private

    def error_message
      e = env['sinatra.error']
      { error: e.message }.to_json
    end
  end
end
