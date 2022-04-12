class DataStage::School < ApplicationRecord
  self.table_name = 'staged_schools'
  include SchoolType

  has_many :school_links, dependent: :destroy, class_name: 'DataStage::SchoolLink',
                          foreign_key: :staged_school_id

  has_one :counterpart_school, class_name: '::School',
                               foreign_key: :urn,
                               primary_key: :urn

  validates :urn, presence: true, format: { with: /\A\d{6}\z/ }
  validates :name, presence: true
  validates :responsible_body_name, presence: true

  scope :updated_since, ->(datetime) { where(arel_table[:updated_at].gt(datetime)) }

  enum status: {
    open: 'open',
    closed: 'closed',
  }, _prefix: 'gias_status'

  def responsible_body
    DataStage::ResponsibleBody.find_by_name(responsible_body_name)
  end

  def predecessors
    School.where(urn: school_links.any_predecessor.map(&:link_urn))
  end

  def predecessor
    link = school_links.any_predecessor.order(created_at: :asc).last
    School.find_by(urn: link.link_urn) unless link.nil?
  end

  def address_components
    [address_1, address_2, address_3, town, county, postcode].reject(&:blank?)
  end

  def address
    address_components.join(', ')
  end

  def staged_attributes
    Rails.logger.error("Did not find responsible body: #{responsible_body_name}") if responsible_body.blank?

    attributes
      .except('id', 'responsible_body_name', 'created_at', 'updated_at')
      .merge(responsible_body:)
  end
end
