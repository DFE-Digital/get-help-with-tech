class Support::NewUserSchoolForm
  include ActiveModel::Model

  MAX_NUMBER_OF_SUGGESTED_SCHOOLS = 50

  attr_accessor :user, :name_or_urn

  def matching_schools
    School
      .matching_name_or_urn(@name_or_urn)
      .includes(:responsible_body)
      .order(:name)
      .limit(MAX_NUMBER_OF_SUGGESTED_SCHOOLS)
  end
end
