class Support::SchoolSuggestionForm
  include ActiveModel::Model

  MAX_NUMBER_OF_SUGGESTED_SCHOOLS = 50

  attr_accessor :name_or_urn, :school_urn

  validates :name_or_urn, length: { minimum: 3 }

  def matching_schools
    school_by_urn.present? ? [school_by_urn] : schools_by_name_or_urn
  end

  def matching_schools_options
    matching_schools.map { |school| option_for(school) }
  end

private

  def option_for(school)
    meta_info = [school.urn, school.town, school.postcode]
      .reject(&:blank?)
      .compact
      .join(', ')
    OpenStruct.new(
      id: school.id,
      name: "#{school.name} (#{meta_info})",
      urn: school.urn,
    )
  end

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
