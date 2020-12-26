module Sessions
  class Authenticate
    include Interactor

    def call
      lock_check_code
      check_timestamp
      request_token
      context.cookies[:_session_id] = context.session.id
    end

    private

    def lock_check_code
      context.check_code = ::CheckCode.find_by(code: context.check, archived: false)
      unauthorized = context.check.blank? || context.check_code.blank?
      raise ::Twitch::AuthorizeService::UnauthorizedException.new('unauthorized request') if unauthorized
      
      context.check_code.lock!
      context.check_code.update!(archived: true)
    end

    def check_timestamp
      return unless context.check_code.created_at < 1.minute.ago
      
      context.check_code.archived = true
      context.check_code.save!
      raise ::Twitch::AuthorizeService::UnauthorizedException.new('unauthorized request')
    end

    def request_token
      response = ::Twitch::TokenService.new(context.session).request
      context.session.data = response.body
      return if response.success? && context.session.save

      raise ActiveRecord::RecordInvalid
    end
  end
end
