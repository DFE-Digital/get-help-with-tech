require 'open-uri'
require 'csv'

class ImportBTWifiVouchersService
  def initialize(csv_url)
    @csv_url = csv_url
  end

  def call
    BTWifiVoucher.transaction do
      csv = URI.parse(@csv_url).read
      CSV.parse(csv, headers: true).select do |row|
        responsible_body_name = row['Assigned to responsible body name']&.strip
        responsible_body = find_responsible_body!(responsible_body_name)
        BTWifiVoucher.create!(
          username: row['Username'].strip,
          password: row['Password'].strip,
          responsible_body:,
        )
      end
    end
  end

private

  def find_responsible_body!(name)
    ResponsibleBody.find_by!(name:) if name.present?
  rescue ActiveRecord::RecordNotFound
    raise ArgumentError, "could not find responsible body with name '#{name}'"
  end
end
