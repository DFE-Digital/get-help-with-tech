class SocialCareProvision < CompulsorySchool
  def institution_type
    'local_authority'
  end

  def techsource_urn
    "SCL_#{responsible_body.gias_id}"
  end
end
