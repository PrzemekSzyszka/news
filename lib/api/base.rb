require './config/environment'
require 'sinatra'
require 'json'

module API
  class Base < Sinatra::Base
    set :show_exceptions => false

    configure do
      use ActiveRecord::ConnectionAdapters::ConnectionManagement
    end

    error { |err|
      Rack::Response.new(
        [{'error' => err.message}.to_json],
        404,
        {'Content-type' => 'application/json'}
      ).finish
    }
  end
end
