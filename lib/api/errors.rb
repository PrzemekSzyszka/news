module Errors
  class AuthenticationError < StandardError
    def initialize(msg = 'Authentication failed')
      super
    end
  end

  class AuthorizationError < StandardError
    def initialize(msg = 'Unauthorized')
      super
    end
  end
end
