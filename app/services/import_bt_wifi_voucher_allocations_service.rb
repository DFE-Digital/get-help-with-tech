require 'open-uri'
require 'csv'

class ImportBTWifiVoucherAllocationsService
  def initialize(csv_url)
    @csv_url = csv_url
  end

  def call
    BTWifiVoucherAllocation.transaction do
      csv = URI.parse(@csv_url).read
      CSV.parse(csv, headers: true).select do |row|
        responsible_body_name = row['Responsible body name']&.strip
        responsible_body = find_responsible_body!(responsible_body_name)
        BTWifiVoucherAllocation.create!(
          responsible_body:,
          amount: row['Allocation'].strip,
        )
      end
    end
  end

private

  def find_responsible_body!(name)
    ResponsibleBody.find_by!(name:)
  rescue ActiveRecord::RecordNotFound
    raise ArgumentError, "could not find responsible body with name '#{name}'"
  end
end
