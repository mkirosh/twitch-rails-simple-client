class StreamsController < ApplicationController
  before_action :require_session

  def index
    @streams = {}
    @streams = channels_list if params[:q].present?
  end

  def show
    @stream = stream.body.dig('data', 0)
  end

  private

  def channels_service
    ::Twitch::ChannelsService.new(current_session)
  end

  def stream
    channels_service.details(params.require(:id)).tap do |response|
      raise ActiveRecord::RecordNotFound unless response.success?
    end
  end

  def channels_list
    channels_service.search(params[:q]).body['data']
  end
end
