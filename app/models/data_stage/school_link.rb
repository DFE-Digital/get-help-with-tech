class DataStage::SchoolLink < ApplicationRecord
  self.table_name = 'staged_school_links'

  belongs_to :staged_school, class_name: 'DataStage::School', inverse_of: :school_links

  validates :link_urn, presence: true, format: { with: /\A\d{6}\z/ }, uniqueness: { scope: :staged_school_id }
  validates :link_type, presence: true
end
