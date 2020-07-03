class MobileNetwork < ApplicationRecord
  has_many :extra_mobile_data_requests, dependent: :destroy

  validates :brand, presence: true, uniqueness: true

  enum participation_in_pilot: {
    'Offers data now': 'yes',
    'Not participating': 'no',
    'May offer data when service launches': 'maybe',
  }

  def self.participating_in_pilot
    where.not(participation_in_pilot: [nil, MobileNetwork.participation_in_pilots.key('maybe')])
  end
end
