require 'csv'

class DonatedDeviceRequestsExporter
  attr_reader :filename

  def initialize(filename = nil)
    @filename = filename
  end

  def export(query = donated_device_requests)
    if filename
      CSV.open(filename, 'w') do |csv|
        render(csv, query)
      end
      nil
    else
      CSV.generate(headers: true) do |csv|
        render(csv, query)
      end
    end
  end

  def self.headings
    %w[
      id
      created_at
      urn
      shipTo
      soldTo
      full_name
      email_address
      telephone_number
      device_types
      units
    ].freeze
  end

private

  def render(csv, query)
    csv << self.class.headings
    query.find_each do |request|
      csv << [
        request.id,
        request.created_at,
        request.school.urn,
        request.school.computacenter_reference,
        request.school.responsible_body.computacenter_reference,
        request.user.full_name,
        request.user.email_address,
        request.user.telephone,
        request.device_types.join(','),
        request.units,
      ]
    end
  end

  def donated_device_requests
    DonatedDeviceRequest.all.includes(:user, school: :responsible_body).order(:asc)
  end
end
