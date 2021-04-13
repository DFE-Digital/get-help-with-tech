class LaFundedPlace < CompulsorySchool
  def institution_type
    'funded_places'
  end

  def name
    'State-funded pupils in independent settings'
  end

  def techsource_urn
    "iss #{responsible_body.name.downcase}"
  end
end
