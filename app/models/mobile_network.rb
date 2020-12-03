class MobileNetwork < ApplicationRecord
  has_many :extra_mobile_data_requests, dependent: :destroy
  has_many :users

  validates :brand, presence: true, uniqueness: true

  enum participation_in_pilot: {
    participating: 'yes',
    not_participating: 'no',
    maybe_participating: 'maybe',
  }

  def self.participating_in_pilot
    participating
  end
end
