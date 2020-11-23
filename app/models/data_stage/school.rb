class DataStage::School < ApplicationRecord
  self.table_name = 'staged_schools'

  RB_NAME_MAP = {
    'Bristol, City of' => 'City of Bristol',
    'Dorset' => 'Dorset Council',
    'Herefordshire, County of' => 'Herefordshire',
    'Kingston upon Hull, City of' => 'Kingston upon Hull',
  }.freeze

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

  def responsible_body
    ResponsibleBody.find_by(name: translated_responsible_body_name)
  end

  def staged_attributes
    Rails.logger.error("Did not find responsible body: #{responsible_body_name}") if responsible_body.blank?

    attributes
      .except('id', 'responsible_body_name', 'created_at', 'updated_at')
      .merge(responsible_body: responsible_body)
  end

private

  def translated_responsible_body_name
    RB_NAME_MAP.fetch(responsible_body_name, responsible_body_name)
  end
end
