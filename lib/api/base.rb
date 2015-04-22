require './config/environment'
require 'sinatra'
require 'json'

module API
  class Base < Sinatra::Base
    set :show_exceptions => false

    configure do
      use ActiveRecord::ConnectionAdapters::ConnectionManagement
    end

    before do
      content_type :json
    end

    error ActiveRecord::RecordNotFound do
      status 404

      error_message
    end

    error ActiveRecord::RecordInvalid do
      status 400

      error_message
    end

    private

    def error_message
      e = env['sinatra.error']
      { error: e.message }.to_json
    end
  end
end
