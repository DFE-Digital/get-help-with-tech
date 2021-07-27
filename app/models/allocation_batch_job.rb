# this is not really a job, it just represents a school's allocation update,
# so suggest renaming
class AllocationBatchJob < ApplicationRecord
  def school
    @school ||= School.where_urn_or_ukprn_or_provision_urn(urn || ukprn).first!
  end
end
