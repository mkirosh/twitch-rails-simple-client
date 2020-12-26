module Twitch
  class ChannelsService < HelixService
    def details(user_id)
      url = self.class.url('/users', { id: user_id })
      client.get(url)
    end

    def search(query)
      url = self.class.url('/search/channels', { query: query, first: 10 })
      client.get(url)
    end
  end
end
