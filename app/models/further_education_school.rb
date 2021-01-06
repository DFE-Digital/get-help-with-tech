class FurtherEducationSchool < School
  def to_param
    ukprn.to_s
  end

  def urn
    ukprn
  end

  def computacenter_identifier
    "fe#{ukprn}"
  end
end
