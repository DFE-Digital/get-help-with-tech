class FurtherEducationSchool < School
  def to_param
    ukprn.to_s
  end

  def urn
    ukprn
  end
end
