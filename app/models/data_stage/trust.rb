class DataStage::Trust < ApplicationRecord
  self.table_name = 'staged_trusts'

  enum status: {
    open: 'open',
    closed: 'closed',
  }

  enum organisation_type: {
    multi_academy_trust: 'Multi-academy trust',
    single_academy_trust: 'Single-academy trust',
  }

  validates :name, presence: true
  validates :organisation_type, presence: true
  validates :gias_group_uid, presence: true

  scope :updated_since, ->(datetime) { where(arel_table[:updated_at].gt(datetime)) }
end
