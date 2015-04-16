require './config/environment'
require 'sinatra'
require 'json'

module API
  class Base < Sinatra::Base
    configure do
      use ActiveRecord::ConnectionAdapters::ConnectionManagement
    end
  end
end
