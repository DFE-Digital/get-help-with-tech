class RemainingDeviceCount < ApplicationRecord
  validates :date_of_count, :remaining_from_devolved_schools, :remaining_from_managed_schools, :total_remaining, presence: true

  before_validation :calculate_total

private

  def calculate_total
    self.total_remaining = remaining_from_devolved_schools + remaining_from_managed_schools
  end
end
