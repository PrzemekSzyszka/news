require_relative '../base'

module API
  class Users < Base
    namespace '/v1' do
      post '/users' do
        User.create!(username: @data['username'], password_hash: @data['password'])
        status 201
      end
    end
  end
end
