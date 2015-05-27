require_relative 'application'

module API
  SUPPORTED_LANGUAGES = ['pl', 'en']
  class Base < Sinatra::Base
    include Errors

    set :show_exceptions => false

    register Sinatra::RespondWith
    register Sinatra::Namespace
    use Rack::Locale
    use Rack::Accept
    helpers Sinatra::UrlForHelper
    respond_to :json, :xml

    configure do
      use ActiveRecord::ConnectionAdapters::ConnectionManagement
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path = Dir[File.join("./", 'locales', '*.yml')]
      I18n.backend.load_translations
      I18n.enforce_available_locales = false
    end

    before do
      @data = ''
      content_type = request.content_type.blank? ? 'application/json' : request.content_type
      request.accept << content_type if request.accept.blank?

      request.accept.each do |accept|
        case accept.to_s
        when 'application/xml', 'text/xml'
          body = request.body.read
          @data = Hash.from_xml(body.gsub("\n", ""))
          @data = @data['hash'] if @data.present?
        else
          body = request.body.read.to_s
          @data = JSON.parse body if body.present?
        end
      end
      if request.env['HTTP_ACCEPT'] && version = request.env['HTTP_ACCEPT'].split(';').find { |e| /version/ =~ e }
        version = version.split('=')[1]
        request.path_info = "/v#{version}#{request.path_info}" if version.present?
      end
      set_cache_header(request.path_info)
      set_current_language
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
      respond_with error: I18n.t(:unauthorized)
    end

    error AuthorizationError do
      status 403
      respond_with error: I18n.t(:forbidden)
    end

    error LanguageNotSupportedError do
      status 406
      respond_with error: I18n.t(:not_acceptable)
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

    def set_cache_header(path_info)
      cache_control :public, :max_age => 30 if path_info.to_s.include?('/recent')
    end

    def set_current_language
      if request.env['HTTP_ACCEPT_LANGUAGE'].present?
        cset     = Rack::Accept::Charset.new(request.env['HTTP_ACCEPT_LANGUAGE'])
        language = cset.qvalues.max[0]
        raise LanguageNotSupportedError unless SUPPORTED_LANGUAGES.include?(language)
        I18n.locale = language
      end
    end

    def error_message
      e = env['sinatra.error']
      respond_with error: e.message
    end
  end
end
