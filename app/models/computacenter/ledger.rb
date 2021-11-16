require 'csv'

module Computacenter
  class Ledger
    attr_accessor :user_changes

    def initialize(user_changes: nil)
      @user_changes = user_changes || default_user_changes
    end

    def to_csv
      CSV.generate do |csv|
        csv << self.class.headers

        user_changes.each do |user_change|
          csv << csv_row(user_change)
        end
      end
    end

    def self.headers
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
        'Original First Name',
        'Original Last Name',
        'Original Email',
        'Original Telephone',
        'Original Responsible Body',
        'Original Responsible Body URN',
        'Original CC Sold To Number',
        'Original School',
        'Original School URN',
        'Original CC Ship To Number',
      ]
    end

  private

    def default_user_changes
      @user_changes ||= UserChange.all.order(:updated_at_timestamp)
    end

    def csv_row(user_change)
      [
        user_change.first_name,
        user_change.last_name,
        user_change.email_address,
        user_change.telephone,
        user_change.responsible_body,
        user_change.responsible_body_urn,
        user_change.cc_sold_to_number,
        user_change.school,
        user_change.school_urn,
        user_change.cc_ship_to_number,
        user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
        user_change.updated_at_timestamp.utc.strftime('%R'),
        user_change.updated_at_timestamp.utc.iso8601,
        user_change.type_of_update,
        user_change.original_first_name,
        user_change.original_last_name,
        user_change.original_email_address,
        user_change.original_telephone,
        user_change.original_responsible_body,
        user_change.original_responsible_body_urn,
        user_change.original_cc_sold_to_number,
        user_change.original_school,
        user_change.original_school_urn,
        user_change.original_cc_ship_to_number,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end
  end
end
