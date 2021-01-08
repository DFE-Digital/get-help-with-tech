require 'csv'

module Importers
  class FeCsv
    attr_reader :path

    def initialize(path_to_csv:)
      @path = path_to_csv
    end

    # UKPRN
    # URN (if applicable)
    # Provider name
    # Provider type
    # Contact name
    # Contact email
    # Contact phone
    # Contact address (full)
    # Main address line 1
    # Main address line 2
    # Main address line 3
    # Main town / city
    # Main county
    # Main postcode

    def call
      rows.each do |row|
        school = School.find_by(ukprn: row['UKPRN'])

        if school.nil?
          rb = FurtherEducationCollege.create!(
            name: row['Provider name'],
            organisation_type: 'FurtherEducationSchool',
            who_will_order_devices: 'responsible_body',
            address_1: row['Main address line 1'],
            address_2: row['Main address line 2'],
            address_3: row['Main address line 3'],
            town: row['Main town / city'],
            county: row['Main county'],
            postcode: row['Main postcode'],
          )

          school = FurtherEducationSchool.create!(
            responsible_body: rb,
            ukprn: row['UKPRN'],
            name: row['Provider name'],
            address_1: row['Main address line 1'],
            address_2: row['Main address line 2'],
            address_3: row['Main address line 3'],
            town: row['Main town / city'],
            county: row['Main county'],
            postcode: row['Main postcode'],
          )
        end

        contact = school.contacts.first_or_create!(
          email_address: row['Contact email'],
          full_name: row['Contact name'],
          role: 'contact',
          title: nil,
          phone_number: row['Contact phone'],
        )

        next if school.preorder_information.present?

        school.create_preorder_information!(
          who_will_order_devices: 'responsible_body',
          school_contact: contact,
        )
      end
    end

  private

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end
