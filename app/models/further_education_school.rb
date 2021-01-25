class FurtherEducationSchool < School
  def to_param
    ukprn.to_s
  end

  def urn
    ukprn
  end

  def institution_type
    case fe_type
    when 'sixth_form_college', 'agricultural_and_horticultural_college'
      'college'
    when 'special_post_16_institution'
      'institution'
    else
      'organisation'
    end
  end

  def school_type
    fe_type
  end
end
