module Twitch
  class AuthorizeService < Service
    class UnauthorizedException < RuntimeError; end

    class << self
      def url(check)
        authorize = super('/oauth2/authorize')
        params = url_params
        params[:state] = check
        "#{authorize}#{url_query(params)}"
      end

      private

      def url_params
        credentials = Rails.application.credentials[:twitch]
        {
          **credentials.slice(:client_id, :redirect_uri),
          force_verify: true,
          response_type: :code,
          scope: 'chat:edit chat:read'
        }
      end
    end
  end
end
