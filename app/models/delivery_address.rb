class DeliveryAddress < ApplicationRecord
  belongs_to :school

  before_create :generate_computacenter_identifier

  after_update :maybe_generate_user_changes

  def computacenter_identifier_otherwise_urn
    computacenter_identifier || school.urn
  end

private

  def maybe_generate_user_changes
    school.send(:maybe_generate_user_changes)
  end

  def generate_computacenter_identifier
    if school.is_further_education?
      self.computacenter_identifier = "#{school.ukprn}-A"
    end
  end
end
