require 'csv'

module Importers
  class FeAddresses
    attr_reader :path

    def initialize(path_to_csv:)
      @path = path_to_csv
    end

    # "UKPRN",
    # "Provider name",
    # "Location name",
    # "Address line 1",
    # "Address line 2",
    # "Address line 3",
    # "Town / City",
    # "County",
    # "Postcode"

    def call
      rows.each do |row|
        school = School.find_by(ukprn: row['UKPRN'])

        raise "School with ukprn: #{row['UKPRN']} could not be found" unless school

        address = DeliveryAddress.new

        address.name = row['Location name'].presence || row['Provider name']

        address.address_1 = row['Address line 1']
        address.address_2 = row['Address line 2']
        address.address_3 = row['Address line 3']

        address.town = row['Town / City']
        address.county = row['County']
        address.postcode = row['Postcode']

        school.delivery_addresses << address
      end
    end

  private

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end
