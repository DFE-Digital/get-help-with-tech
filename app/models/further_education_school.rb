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

  def type_label
    case fe_type
    when 'general_fe_and_tertiary'
      'General FE and Tertiary'
    when 'sixth_form_college'
      'Sixth Form College'
    when 'independent_learning_provider'
      'Independent Learning Provider'
    when 'agricultural_and_horticultural_college'
      'Agricultural & Horticultural College'
    when 'special_post_16_institution'
      'Post-16 Institution (SPI)'
    when '16_19_other'
      '16 to 19 other'
    when 'local_authority'
      'Local Authority'
    when 'art_and_design_college'
      'Art and Design College'
    when 'higher_education_provider'
      'Higher Education Provider'
    else
      'Other'
    end
  end
end
