require_relative 'base'
require_relative '../models/user'

module API
  class Users < Base

    post '/users' do
      User.create(username: params[:username], password: params[:password])
      status 201
    end
  end
end
