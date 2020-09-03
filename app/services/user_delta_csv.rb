require 'csv'

class UserDeltaCsv
  attr_reader :start_range, :end_range

  def initialize(start_range: 24.hours.ago, end_range: Time.now)
    @start_range = start_range
    @end_range = end_range
  end

  def to_csv
    CSV.generate do |csv|
      csv << headers

      versions.each do |version|
        next unless version.event == 'create'

        user = user_for_version(version)

        csv << [
          user.first_name,
          user.last_name,
          user.email_address,
          user.telephone,
          user.responsible_body&.name,
          user.responsible_body&.computacenter_identifier,
          user.responsible_body&.computacenter_reference,
          user.school&.name,
          user.school&.urn,
          user.school&.computacenter_reference,
          version.created_at.utc.strftime('%d/%m/%Y'),
          version.created_at.utc.strftime('%R'),
          version.created_at.utc.iso8601,
          change_type_for_version(version),
          version.changeset["email_address"][0]
        ]
      end
    end
  end

private

  def user_for_version(version)
    case version.event
    when "create"
      # TODO needs caching
      version.item
    when "update"
      # TODO needs caching
      version.item
    when "destroy"
      User.new
    end
  end

  def change_type_for_version(version)
    case version.event
    when "create"
      "New"
    when "update"
      "Change"
    when "destroy"
      "Remove"
    end
  end

  def versions
    # TODO eager loading
    PaperTrail::Version.where(item_type: 'User', created_at: start_range..end_range)
  end

  def headers
    [
      'First Name',
      'Last Name',
      'Email',
      'Telephone',
      'Responsible Body',
      'Responsible Body URN',
      'CC Sold To Number',
      'School',
      'School URN',
      'CC Ship To Number',
      'Date of Update', # "24/08/2020" / "dd/mm/yyyy"
      'Time of Update', # 24 hour clock
      'Timestamp of Update', # ISO
      'Type of Update', # New / Change / Remove
      'Original Email'
    ]
  end
end
