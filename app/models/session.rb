class Session < ApplicationRecord
  attr_accessor :code

  validates :token, presence: true

  def data
    super ? OpenStruct.new(super) : nil
  end

  def token
    data&.access_token
  end

  def refresh_token
    data&.refresh_token
  end

  def expires_in
    data&.expires_in&.to_i&.seconds
  end
end
