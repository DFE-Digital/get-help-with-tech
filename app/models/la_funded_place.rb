class LaFundedPlace < CompulsorySchool
  def institution_type
    'local_authority'
  end

  def techsource_urn
    "iss-#{responsible_body.name}".parameterize
  end
end
