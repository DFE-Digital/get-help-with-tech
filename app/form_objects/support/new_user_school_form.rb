class Support::NewUserSchoolForm
  include ActiveModel::Model

  MAX_NUMBER_OF_SUGGESTED_SCHOOLS = 50

  attr_accessor :user, :name_or_urn, :school_urn

  validates :name_or_urn, length: { minimum: 3 }

  def matching_schools
    school_by_urn.present? ? [school_by_urn] : schools_by_name_or_urn
  end

private

  def school_by_urn
    if @school_urn
      School.gias_status_open.find_by(urn: @school_urn)
    end
  end

  def schools_by_name_or_urn
    School
      .matching_name_or_urn(@name_or_urn)
      .includes(:responsible_body)
      .order(:name)
      .limit(MAX_NUMBER_OF_SUGGESTED_SCHOOLS)
  end
end
