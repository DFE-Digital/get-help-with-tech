class Staging::School < ApplicationRecord
  self.table_name = 'staged_schools'

  validates :urn, presence: true, format: { with: /\A\d{6}\z/ }
  validates :name, presence: true
  validates :responsible_body_name, presence: true

  enum status: {
    open: 'open',
    closed: 'closed',
  }

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
  }, _suffix: true

end
