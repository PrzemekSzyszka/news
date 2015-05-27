module Errors
  class AuthenticationError < StandardError
    def initialize(msg = I18n.t(:authentication_failed))
      super
    end
  end

  class AuthorizationError < StandardError
    def initialize(msg = I18n.t(:unauthorized))
      super
    end
  end
end
