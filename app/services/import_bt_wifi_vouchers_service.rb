require 'open-uri'
require 'csv'

class ImportBTWifiVouchersService
  def initialize(csv_url)
    @csv_url = csv_url
  end

  def call
    csv = URI.parse(@csv_url).read
    CSV.parse(csv, headers: true).select do |row|
      responsible_body_name = row['Assigned to responsible body name']&.strip
      responsible_body = ResponsibleBody.find_by(name: responsible_body_name) if responsible_body_name.present?
      BTWifiVoucher.create!(
        username: row['Username'].strip,
        password: row['Password'].strip,
        responsible_body: responsible_body,
      )
    end
  end
end
