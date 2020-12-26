module Twitch
  class HelixService < Service
    URI = 'https://api.twitch.tv'.freeze

    class << self
      def url(path = '', params = {})
        helix = super('/helix')
        "#{helix}#{path}#{url_query(params)}"
      end
    end
  end
end
