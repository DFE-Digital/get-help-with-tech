class UserOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, polymorphic: true
  # belongs_to :responsible_body, -> { where(organisation_type: 'ResponsibleBody') }, foreign_key: 'organisation_id'
  # belongs_to :school, -> { where(organisation_type: 'School') }, foreign_key: 'organisation_id'

  scope :schools, -> { where(organisation_type: 'School') }
  scope :responsible_bodies, -> { where(organisation_type: 'ResponsibleBody') }

  validates :organisation_id, uniqueness: { scope: [:user_id, :organisation_type] }

  def self.trusts
    where(organisation_type: 'ResponsibleBody')
      .includes(:responsible_body)
      .where(responsible_bodies: {type: 'Trust'})
  end

  def self.local_authorities
    where(organisation_type: 'ResponsibleBody')
      .includes(:responsible_body)
      .where(responsible_bodies: {type: 'LocalAuthority'})
  end
end
