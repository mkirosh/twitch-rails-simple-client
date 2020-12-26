class WelcomeController < ApplicationController
  def index
    redirect_to streams_path
  end
end
