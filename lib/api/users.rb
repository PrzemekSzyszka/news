require_relative 'base'

module API
  class Users < Base

    post '/users' do
      password = BCrypt::Password.create(@data['password'])
      User.create!(username: @data['username'], password: password)
      status 201
    end
  end
end
