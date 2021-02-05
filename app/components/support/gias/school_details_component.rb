class Support::Gias::SchoolDetailsComponent < ViewComponent::Base

  def initialize(school:, viewer: nil)
    @school = school
    @viewer = viewer
  end

  def rows
    array = []
    array << { key: 'URN', value: @school.urn }
    array << school_type_row
    array << { key: 'Address', value: @school.address_components }
    array.concat(links)
  end

private

  def links
    @school.school_links.order(created_at: :desc).map do |link|
      link_row(link)
    end
  end

  def link_row(link)
    school = School.find_by(urn: link.link_urn)

    row = {
      key: link.link_type.humanize,
      value: describe_link(link.link_urn, school)
    }

    row.merge!({
      action: 'View',
      action_path: support_school_path(urn: link.link_urn)
    }) if school

    row
  end

  def school_type_row
    {
      key: 'Setting',
      value: @school.human_for_school_type,
    }
  end

  def describe_link(urn, school)
    if school
      "#{school.name} (#{school.urn})"
    else
      "#{urn} (Not on service)"
    end
  end
end
