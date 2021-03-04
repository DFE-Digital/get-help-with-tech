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

  scope :excluded_fe_networks, -> { where(excluded_fe_network: true) }
  scope :fe_networks, -> { participating.where(excluded_fe_network: false) }

  def pathsafe_brand
    brand.to_s
         .downcase
         .gsub(/[^a-z0-9]+/, '_')
         .gsub(/^_+(.*)/, '\1')
         .gsub(/^(.*)_$/, '\1')
  end
end
