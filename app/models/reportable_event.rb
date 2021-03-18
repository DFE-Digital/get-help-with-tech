class ReportableEvent < ApplicationRecord
  has_paper_trail

  belongs_to :record, polymorphic: true, optional: true

  before_validation :populate_defaults!, on: :create

  validates :event_name, presence: true

  def populate_defaults!
    self.event_time ||= Time.zone.now.utc
  end
end
