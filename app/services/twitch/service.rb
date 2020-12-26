module Twitch
  ##
  # This class contains the basic logic shared by all services in charge of making REST requerst to Twitch API
  class Service
    URI = 'https://id.twitch.tv'.freeze
    attr_reader :session

    class << self
      ##
      # Generates a sanitized URL path using 'https://id.twitch.tv' as base
      # @example
      #   ::Twitch::Service.url('mypath', { foo: 'val', var: 'val' })
      #   'https://id.twitch.tv/mypath?foo=val&var=val'

      def url(path, params = {})
        "#{self::URI}#{path}#{::Twitch::Service.url_query(params)}"
      end

      def url_query(params)
        params.any? ? "?#{::Faraday::FlatParamsEncoder.encode(params)}" : nil
      end

      def client
        Faraday.new(headers: headers) do |conn|
          conn.response :json
          conn.request :json
        end
      end
    end

    def initialize(session)
      @session = session
    end

    def client
      headers = {}
      headers['Client-Id'] = Rails.application.credentials.dig(:twitch, :client_id)
      Faraday.new(headers: headers) do |conn|
        conn.authorization :Bearer, session.token if session.token
        conn.response :json
        conn.request :json
      end
    end
  end
end
