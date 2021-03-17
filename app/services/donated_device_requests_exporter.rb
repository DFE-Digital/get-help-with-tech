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
      School.where(id: request.schools).includes(:responsible_body).each do |school|
        csv << [
          request.id,
          request.completed_at,
          school.urn,
          school.computacenter_reference,
          school.responsible_body.computacenter_reference,
          request.user.full_name,
          request.user.email_address,
          request.user.telephone,
          request.device_types.join(','),
          request.units,
        ]
      end
    end
  end

  def donated_device_requests
    DonatedDeviceRequest.complete.includes(:user).order(completed_at: :asc)
  end
end
