module Sessions
  class Manage
    include Interactor
    EXPIRES_AFTER = 7.days.freeze

    def call
      check_session_time
      refresh_token
      check_status
      clean_cookies
    end

    private

    def clean_cookies
      return if context.error.blank?

      context.session.delete
      context.cookies.delete(:_session_id)
    end

    def client
      @client ||= ::Twitch::TokenService.new(context.session)
    end

    def check_session_time
      return if DateTime.now < EXPIRES_AFTER.since(context.session.created_at)
      
      context.error = 'Session expired'
    end

    def check_status
      return if context.error.present?
      
      context.error = 'Token invalidated' unless client.status.success?
    end

    def refresh_token
      return if context.error.present?

      session = context.session
      return if DateTime.now < session.expires_in.since(session.created_at)

      response = ::Twitch::TokenService.new(session).request
      context.session.data = response.body
      return if response.success? && session.save

      context.error = 'Token refresh unauthorized'
    end

  end
end
