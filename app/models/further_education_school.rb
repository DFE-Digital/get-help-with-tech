class FurtherEducationSchool < School
  before_validation :generate_fake_ukprn, on: [:create]

  def to_param
    ukprn.to_s
  end

  def urn
    ukprn
  end

private

  def generate_fake_ukprn
    self.ukprn ||= rand(10_000_000..99_999_999)
  end
end
