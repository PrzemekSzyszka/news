require_relative 'base'
require_relative '../models/user'

module API
  class Users < Base

    post '/users' do
      user = params[:user]
      User.create!(username: user[:username], password: user[:password])
      status 201
    end
  end
end
