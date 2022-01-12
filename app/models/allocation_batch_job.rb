class AllocationBatchJob < ApplicationRecord
  def school
    @school ||= School.where_urn_or_ukprn_or_provision_urn(urn || ukprn).first!
  end

  def delta_adjusted?
    allocation_delta != applied_allocation_delta
  end
end
