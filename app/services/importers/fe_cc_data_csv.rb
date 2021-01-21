require 'csv'

module Importers
  class FeCcDataCsv
    attr_reader :path

    def initialize(path_to_csv:)
      @path = path_to_csv
    end

    # fe_ukprn # FE12345678
    # ship_to
    # sold_to

    def call
      rows.each do |row|
        puts "processing #{row['fe_ukprn']}, #{row['ship_to']}, #{row['sold_to']}"

        ukprn = row['fe_ukprn'].gsub('FE', '').strip
        ship_to = row['ship_to'].strip
        sold_to = row['sold_to'].strip

        school = School.includes(:responsible_body).find_by(ukprn: ukprn)

        raise if school.nil?

        school.update!(computacenter_reference: ship_to)
        school.responsible_body.update!(computacenter_reference: sold_to)
      end
    end

  private

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end
