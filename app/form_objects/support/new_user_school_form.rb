class Support::NewUserSchoolForm
  include ActiveModel::Model

  MAX_NUMBER_OF_SUGGESTED_SCHOOLS = 50

  attr_accessor :user, :name_or_urn, :urn

  def initialize(user:, name_or_urn: nil)
    @user = user
    @name_or_urn = name_or_urn
  end

  def matching_schools
    @matching_schools ||= School
      .matching_name_or_urn(@name_or_urn)
      .includes(:responsible_body)
      .where.not(id: @user.school_ids)
      .order(:name)
      .limit(MAX_NUMBER_OF_SUGGESTED_SCHOOLS)
      .map { |school| option_for(school) }
  end

  def matching_schools_capped?
    matching_schools.size == MAX_NUMBER_OF_SUGGESTED_SCHOOLS
  end

  def maximum_matching_schools
    MAX_NUMBER_OF_SUGGESTED_SCHOOLS
  end

private

  def option_for(school)
    meta_info = [school.urn, school.town, school.postcode].reject(&:blank?).compact
    display_name = "#{school.name} (#{meta_info.join(', ')})"
    OpenStruct.new(
      id: school.id,
      name: display_name,
      urn: school.urn,
      responsible_body: school.responsible_body,
      responsible_body_id: school.responsible_body_id,
    )
  end
end
