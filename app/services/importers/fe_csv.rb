require 'csv'

module Importers
  class FeCsv
    attr_reader :path

    def initialize(path_to_csv:)
      @path = path_to_csv
    end

    # UKPRN
    # URN
    # Name
    # ProvType
    # Fmallocation
    # Full Name
    # Job Title
    # First Name
    # Last Name
    # Email
    # Business Phone
    # Address Line 1 (Organisation) (Organisation)
    # Address Line 2 (Organisation) (Organisation)
    # Address Line 3 (Organisation) (Organisation)
    # Town / City (Organisation) (Organisation)
    # County (Organisation) (Organisation)
    # Postcode (Organisation) (Organisation)

    def call
      schools_found = 0
      schools_created = 0
      rbs_created = 0

      rows.each do |row|
        # TODO: we will want to skip certain rows for each import run as we do in batches
        # next if row['ProvType'].underscore.gsub(' (spi)', '').gsub(' ', '_').gsub('&', 'and') == '???'

        if row['URN'].present?
          school = School.find_by(urn: row['URN'])

          if school
            school.update!(ukprn: row['UKPRN'])
          else
            school = School.find_by(ukprn: row['UKPRN'])
          end
        else
          school = School.find_by(ukprn: row['UKPRN'])
        end

        if school.nil?
          rb = FurtherEducationCollege.create!(
            name: row['Name'],
            organisation_type: 'FurtherEducationSchool',
            who_will_order_devices: 'responsible_body',
            address_1: row['Address Line 1'],
            address_2: row['Address Line 2'],
            address_3: row['Address Line 3'],
            town: row['Town / City'],
            county: row['County'],
            postcode: row['Postcode'],
          )

          school = FurtherEducationSchool.create!(
            responsible_body: rb,
            ukprn: row['UKPRN'],
            urn: row['URN'],
            name: row['Name'],
            fe_type: row['ProvType'].underscore.gsub(' (spi)', '').gsub(' ', '_').gsub('-', '_').gsub('&', 'and'),
            address_1: row['Address Line 1'],
            address_2: row['Address Line 2'],
            address_3: row['Address Line 3'],
            town: row['Town / City'],
            county: row['County'],
            postcode: row['Postcode'],
          )
          schools_created += 1
        else
          schools_found += 1
        end

        if school.responsible_body
          if school.responsible_body.model_name.name == 'FurtherEducationCollege'
            # good
          else # delink
            rb = FurtherEducationCollege.create!(
              name: row['Name'],
              organisation_type: 'FurtherEducationSchool',
              who_will_order_devices: 'responsible_body',
              address_1: row['Address Line 1'],
              address_2: row['Address Line 2'],
              address_3: row['Address Line 3'],
              town: row['Town / City'],
              county: row['County'],
              postcode: row['Postcode'],
            )
            rbs_created += 1

            school.update!(responsible_body: rb)
          end
        end

        contact = school.contacts.find_or_create_by!(
          email_address: row['Email'],
          full_name: row['Full Name'],
          role: 'contact',
          title: row['Job Title'],
          phone_number: row['Business phone'],
        )

        (school.preorder_information || school.build_preorder_information).update!(
          who_will_order_devices: 'responsible_body',
          school_contact: contact,
        )
      end

      puts "schools found #{schools_found}"
      puts "schools created #{schools_created}"
      puts "rbs created #{rbs_created}"
    end

  private

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end
