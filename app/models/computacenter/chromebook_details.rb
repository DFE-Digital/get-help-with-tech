require 'csv'

module Computacenter
  class ChromebookDetails
    HEADERS = [
      'Responsible Body URN',
      'Responsible Body Name',
      'School Name',
      'School URN',
      'Google Domain',
      'Valid Recovery Off Domain Email Address',
      'Date',
      'Time',
    ].freeze

    def self.to_csv
      CSV.generate do |csv|
        csv << HEADERS

        PreorderInformation
          .includes(school: :responsible_body)
          .where(will_need_chromebooks: 'yes')
          .order(updated_at: :asc)
          .each do |i|
          csv << [
            i.school.responsible_body.computacenter_identifier,
            i.school.responsible_body.name,
            i.school.name,
            i.school.urn,
            i.school_or_rb_domain,
            i.recovery_email_address,
            i.updated_at.utc.strftime('%d/%m/%Y'),
            i.updated_at.utc.strftime('%R'),
          ]
        end
      end
    end
  end
end
