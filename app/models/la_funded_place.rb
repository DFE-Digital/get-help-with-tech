class LaFundedPlace < CompulsorySchool
  def institution_type
    'local_authority'
  end

  def techsource_urn
    "ISS_#{responsible_body.gias_id}"
  end
end
