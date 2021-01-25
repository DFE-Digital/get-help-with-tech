require 'csv'

module Importers
  class SixthFormIncrease
    attr_reader :path

    def initialize(path_to_csv:)
      @path = path_to_csv
    end

    # ukprn # 123456
    # total # allocation to set to

    def call
      rows.each do |row|
        puts "processing #{row['ukprn']}, #{row['total']}"

        ukprn = row['ukprn'].strip
        total = row['total'].strip.to_i

        school = School.includes(:std_device_allocation).find_by(ukprn: ukprn)

        raise 'school not found' if school.nil?

        service = PhilAllocationUpdater.new(school: school, device_type: 'std_device', value: total)
        service.call

        service = PhilSchoolOrderStateAndCapUpdateService.new(school: school, order_state: 'can_order')
        service.update!

        # TODO: suppress invite email
        if school.users.blank?
          school.invite_school_contact
        end
      end

      emails_with_ukprns.each do |array|
        puts "#{array[1]},#{array[0]}"
      end
    end

  private

    def emails_with_ukprns
      @emails_with_ukprns ||= schools.map do |school|
        { school.ukprn => school.send(:device_ordering_organisation).users.where(deleted_at: nil).pluck(:email_address) }
      end.map do |a|
        a.values.flatten.map{|email| [a.keys.first, email]}.flatten
      end.flatten.each_slice(2).to_a.each do |array|
        puts "#{array[1]},#{array[0]}"
      end
    end

    def schools
      @schools ||= School.where(ukprn: ukprns)
    end

    def ukprns
      @ukprn ||= rows.map { |row| row['ukprn'] }
    end

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end
