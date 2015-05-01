require_relative 'base'

module API
  class Users < Base

    post '/users' do
      User.create!(username: @data['username'], password: @data['password'])
      status 201
    end
  end
end
