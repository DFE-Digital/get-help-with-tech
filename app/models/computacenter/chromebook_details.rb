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

        School
          .includes(:responsible_body)
          .where(will_need_chromebooks: 'yes')
          .order(updated_at: :asc)
          .each do |school|
          csv << [
            school.responsible_body.computacenter_identifier,
            school.responsible_body.name,
            school.name,
            school.urn,
            school.school_or_rb_domain,
            school.recovery_email_address,
            school.updated_at.utc.strftime('%d/%m/%Y'),
            school.updated_at.utc.strftime('%R'),
          ]
        end
      end
    end
  end
end
