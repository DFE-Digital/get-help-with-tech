class DataStage::Trust < ApplicationRecord
  self.table_name = 'staged_trusts'

  ATTR_MAP = {
    name: 'Group Name',
    organisation_type: 'Group Type',
    companies_house_number: 'Companies House Number',
    gias_group_uid: 'Group UID',
    status: 'Group Status',
    address_1: 'Group Street',
    address_2: 'Group Locality',
    address_3: 'Group Address 3',
    town: 'Group Town',
    county: 'Group County',
    postcode: 'Group Postcode',
  }.freeze

  enum organisation_type: {
    multi_academy_trust: 'Multi-academy trust',
    single_academy_trust: 'Single-academy trust',
  }

  validates :name, presence: true
  validates :organisation_type, presence: true
  validates :gias_group_uid, presence: true

  scope :updated_since, ->(datetime) { where(arel_table[:updated_at].gt(datetime)) }
end
