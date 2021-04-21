require 'csv'

class Exporters::MnoRequestsCsv
  HEADERS = %w[
    id
    mobile_network_id
    brand
    urn
    ukprn
    school_name
    responsible_body_id
    responsible_body_name
    hashed_account_holder_name
    hashed_normalised_name
    hashed_device_phone_number
    status
    contract_type
    first_completed_at
    created_at
    created_at_date
    updated_at
    updated_at_date
  ].freeze

  def call
    CSV.open(path, 'w') do |csv|
      csv << HEADERS
      requests.find_each do |request|
        csv << [
          request.id,
          request.mobile_network_id,
          request.mobile_network.brand,
          request.school&.urn,
          request.school&.ukprn,
          request.school&.name,
          request.responsible_body_id,
          request.responsible_body&.name,
          request.hashed_account_holder_name,
          request.hashed_normalised_name,
          request.hashed_device_phone_number,
          request.status,
          request.contract_type,
          request.completion_events.first&.event_time,
          request.created_at,
          request.created_at.strftime('%d/%m/%Y'),
          request.updated_at,
          request.updated_at.strftime('%d/%m/%Y'),
        ]
      end
    end
  end

  delegate :path, to: :file

  def delete_generated_csv!
    File.unlink(path)
  end

private

  def file
    @file ||= Tempfile.new
  end

  def requests
    @requests ||= ExtraMobileDataRequest.includes(:mobile_network, :school, :responsible_body, :completion_events)
  end
end
