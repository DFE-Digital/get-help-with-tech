class AllocationBatchJob < ApplicationRecord
  def school
    @school ||= School.where_urn_or_ukprn(urn || ukprn).first!
  end
end
