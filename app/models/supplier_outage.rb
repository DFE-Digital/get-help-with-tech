class SupplierOutage < ApplicationRecord
  validates :start_at, :end_at, presence: true
  validate :end_at_cannot_be_in_the_past, on: :create # allows active outage to end early
  validate :start_at_must_be_before_end_at

  scope :current, lambda {
    now = Time.zone.now
    where('start_at < ? and end_at > ?', now, now)
  }

  def end_at_cannot_be_in_the_past
    if end_at.present? && end_at.past?
      errors.add(:end_at, "can't be in the past")
    end
  end

  def start_at_must_be_before_end_at
    if start_at.present? && end_at.present? && start_at >= end_at
      errors.add(:start_at, 'must be before outage end')
    end
  end
end
