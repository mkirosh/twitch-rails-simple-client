class CheckCode < ApplicationRecord
  before_validation :generate
  validates :code, presence: true

  def generate
    self.code = SecureRandom.uuid
  end
end
