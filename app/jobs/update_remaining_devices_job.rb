class UpdateRemainingDevicesJob < ApplicationJob
  def perform
    RemainingDevicesCalculator.new.current_unclaimed_totals.save!
  end
end
