class DataStage::SchoolLink < ApplicationRecord
  self.table_name = 'staged_school_links'

  belongs_to :staged_school, class_name: 'DataStage::School', inverse_of: :school_links

  validates :link_urn, presence: true, format: { with: /\A\d{6}\z/ }, uniqueness: { scope: :staged_school_id }
  validates :link_type, presence: true

  scope :any_predecessor, -> { where(link_type: %i[predecessor predecessor_amalgamated predecessor_merged]) }

  enum link_type: {
    successor: 'Successor',
    predecessor: 'Predecessor',
    sixth_form: 'Sixth Form Centre Link',
    predecessor_amalgamated: 'Predecessor - amalgamated',
    successor_amalgamated: 'Successor - amalgamated',
    predecessor_merged: 'Predecessor - merged',
    successor_merged: 'Successor - merged',
    result_of_amalgamation: 'Result of Amalgamation',
    merged_expansion_and_change_in_age_range: 'Merged - expansion in school capacity and changer in age range',
    merged_change_in_age_range: 'Merged - change in age range',
    expansion: 'Expansion',
    other: 'Other',
    merged_expansion: 'Merged - expansion of school capacity',
    successor_split_school: 'Successor - Split School',
    predecessor_split_school: 'Predecessor - Split School',
  }
end
