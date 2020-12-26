module Twitch
  class TokenService < Service
    class << self
      def url(path = '', params = {})
        token = super('/oauth2')
        "#{token}#{path}#{url_query(params)}"
      end
    end

    def request
      params = session.token ? refresh_params : request_params
      client.post(self.class.url('/token'), params)
    end

    def status
      # byebug
      client.get(self.class.url('/validate'))
      # byebug
    end

    private

    def credentials
      Rails.application.credentials[:twitch]
    end

    def refresh_params
      {
        **credentials,
        refresh_token: session.refresh_token,
        grant_type: :refresh_token
      }
    end

    def request_params
      {
        **credentials,
        code: session.code,
        grant_type: :authorization_code
      }
    end
  end
end
