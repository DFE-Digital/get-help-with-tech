class Support::SchoolSuggestionForm
  include ActiveModel::Model

  MAX_NUMBER_OF_SUGGESTED_SCHOOLS = 20

  attr_accessor :name_or_urn_or_ukprn, :school_urn, :except

  validates :name_or_urn_or_ukprn, length: { minimum: 3 }, unless: ->(form) { form.school_urn.present? }

  def matching_schools
    schools = school_by_urn.presence || schools_by_name_or_urn_or_ukprn
    schools.where.not(id: ids_of_schools_to_exclude)
  end

  def matching_schools_options
    matching_schools.map { |school| option_for(school) }
  end

  def matching_schools_capped?
    matching_schools.size == MAX_NUMBER_OF_SUGGESTED_SCHOOLS
  end

  def maximum_matching_schools
    MAX_NUMBER_OF_SUGGESTED_SCHOOLS
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
      School.gias_status_open.where(urn: @school_urn)
    end
  end

  def schools_by_name_or_urn_or_ukprn
    School
      .matching_name_or_urn_or_ukprn_or_provision_urn(@name_or_urn_or_ukprn)
      .includes(:responsible_body)
      .order(:name)
      .limit(MAX_NUMBER_OF_SUGGESTED_SCHOOLS)
  end

  def ids_of_schools_to_exclude
    @except&.map(&:id) || []
  end
end
