class ApplicationController < ActionController::Base
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_request
  rescue_from ::Twitch::AuthorizeService::UnauthorizedException, with: :unauthorized_request

  def bad_request
    render file: 'public/400.html', status: :bad_request, layout: false
  end

  def unauthorized_request
    render file: 'public/400.html', status: :unauthorized, layout: false
  end

  def unprocessable_request
    render file: 'public/422.html', status: :unprocessable_entity, layout: false
  end

  def require_session
    return unless invalid_session?
    
    check = CheckCode.create!
    redirect_to ::Twitch::AuthorizeService.url(check.code)
  end

  def invalid_session?
    current_session.blank? ||
      ::Sessions::Manage.call({ session: current_session, cookies: session }).error.present?
  end

  def current_session
    @current_session ||= Session.find_by(id: session[:_session_id])
  end

end
