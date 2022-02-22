class Support::Gias::SchoolDetailsComponent < ViewComponent::Base
  def initialize(school:, viewer: nil)
    @school = school
    @viewer = viewer
  end

  def rows
    array = []
    array << urn_row
    array << school_type_row
    array << { key: 'Address', value: @school.address_components }
    array.concat(links)
  end

private

  def urn_row
    row = { key: 'URN', value: @school.urn }

    if @school.counterpart_school
      row.merge!({
        action: 'View',
        action_path: support_school_path(urn: @school.urn),
      })
    end

    row
  end

  def links
    @school.school_links.order(created_at: :desc).map do |link|
      link_row(link)
    end
  end

  def link_row(link)
    urn = link.link_urn
    school = School.find_by(urn:)
    awaiting = DataStage::School.gias_status_open.find_by(urn:)

    row = {
      key: link.link_type.humanize,
    }

    row[:value] = if school
                    "#{school.name} (#{school.urn})"
                  elsif awaiting
                    "#{urn} (waiting to be added)"
                  else
                    "#{urn} (not on service)"
                  end

    if school
      row.merge!({
        action: 'View',
        action_path: support_school_path(urn:),
      })
    elsif awaiting
      row.merge!({
        action: 'View',
        action_path: support_gias_schools_to_add_path(urn:),
      })
    end

    row
  end

  def school_type_row
    {
      key: 'Setting',
      value: @school.human_for_school_type,
    }
  end
end
