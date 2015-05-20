require_relative '../base'

module API
  class Users < Base
    post '/users' do
      redirect '/v1/users', 301, 'Moved permanently'
    end
  end
end
