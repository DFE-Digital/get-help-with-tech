class MobileNetwork < ApplicationRecord
  has_many :extra_mobile_data_requests, dependent: :destroy

  validates :brand, presence: true, uniqueness: true

  enum participation_in_pilot: {
    participating: 'yes',
    not_participating: 'no',
    maybe_participating: 'maybe',
  }

  def self.participating_in_pilot
    participating.or(maybe_participating)
  end
end
