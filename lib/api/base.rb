require_relative 'application'

module API
  class Base < Sinatra::Base
    include Errors

    set :show_exceptions => false

    register Sinatra::RespondWith
    respond_to :json, :xml

    configure do
      use ActiveRecord::ConnectionAdapters::ConnectionManagement
    end

    before do
      @data = ""
      request.accept.each do |type|
        case type.to_s
        when 'application/xml', 'text/xml'
          body = request.body.read
          @data = Hash.from_xml(body.gsub("\n", ""))
          @data = @data['hash'] if @data.present?
        else
          body = request.body.read.to_s
          @data = JSON.parse body if body.present?
        end
      end
    end

    after do
      content_type :json
    end

    error ActiveRecord::RecordNotFound do
      status 404

      error_message
    end

    error ActiveRecord::RecordInvalid do
      status 422

      error_message
    end

    error AuthenticationError do
      status 401
      headers 'WWW-Authenticate' => 'Basic realm="Restricted Area"'
      respond_with error: 'Not authenticated'
    end

    error AuthorizationError do
      status 403
      respond_with error: 'Not authorized'
    end

    helpers do
      def authenticate!
        user = authorize
        return user if user.present?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        raise AuthenticationError
      end

      def authorize
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        if @auth.provided? && @auth.basic? && @auth.credentials
          user = User.find_by(username: @auth.credentials[0])
          user.password == @auth.credentials[1] ? user : nil
        end
      end
    end

    private

    def error_message
      e = env['sinatra.error']
      respond_with error: e.message
    end
  end
end
