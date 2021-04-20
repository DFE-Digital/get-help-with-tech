class LaFundedPlace < CompulsorySchool
  def institution_type
    'local authority'
  end

  def techsource_urn
    "iss #{responsible_body.name.downcase}"
  end
end
