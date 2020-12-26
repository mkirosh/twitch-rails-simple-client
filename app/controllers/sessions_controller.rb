class SessionsController < ApplicationController
  def new
    sessions_params
    ::Sessions::Authenticate.call(sessions_params).error
    redirect_to streams_path
  end

  def code
    value = params[:code].presence
    raise ::Twitch::AuthorizeService::UnauthorizedException.new('unauthorized request') unless value

    value
  end

  def sessions_params
    new_session = Session.new(code: code)
    { session: new_session, check: params[:state], cookies: session }
  end
end
