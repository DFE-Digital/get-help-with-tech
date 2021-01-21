require 'csv'

module Importers
  class SixthFormIncrease
    attr_reader :path

    def initialize(path_to_csv:)
      @path = path_to_csv
    end

    # urn # 123456
    # increase # +ve int

    def call
      rows.each do |row|
        puts "processing #{row['urn']}, #{row['increase']}"

        urn = row['urn'].strip
        increase = row['increase'].strip.to_i

        school = School.includes(:std_device_allocation).find_by(urn: urn)

        raise 'school not found' if school.nil?

        school.update(increased_sixth_form_feature_flag: true)

        current_value = school.std_device_allocation&.raw_allocation || 0
        new_value = current_value + increase

        service = PhilAllocationUpdater.new(school: school, device_type: 'std_device', value: new_value)
        service.call

        service = PhilSchoolOrderStateAndCapUpdateService.new(school: school, order_state: 'can_order')
        service.update!
      end

      emails_with_urns.each do |array|
        puts "#{array[1]},#{array[0]}"
      end
    end

  private

    def emails_with_urns
      @emails_with_urns ||= schools.map do |school|
        { school.urn => school.send(:device_ordering_organisation).users.where(deleted_at: nil).pluck(:email_address) }
      end.map do |a|
        a.values.flatten.map{|email| [a.keys.first, email]}.flatten
      end.flatten.each_slice(2).to_a
    end

    def schools
      @schools ||= School.where(urn: urns)
    end

    def urns
      @urn ||= rows.map { |row| row['urn'] }
    end

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end
