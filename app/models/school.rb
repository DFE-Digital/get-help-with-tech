class School < ApplicationRecord
  belongs_to :responsible_body
  has_many   :device_allocations, class_name: 'SchoolDeviceAllocation'

  has_many :contacts, class_name: 'SchoolContact', inverse_of: :school

  validates :urn, presence: true, format: { with: /\A\d{6}\z/ }
  validates :name, presence: true

  enum phase: {
    primary: 'primary',
    secondary: 'secondary',
    all_through: 'all_through',
    sixteen_plus: 'sixteen_plus',
    nursery: 'nursery',
    phase_not_applicable: 'phase_not_applicable',
  }

  enum establishment_type: {
    academy: 'academy',
    free: 'free',
    local_authority: 'local_authority',
    special: 'special',
    other_type: 'other_type',
  }

  def allocation_for_type!(device_type)
    device_allocations.find_by_device_type!(device_type)
  end
end
