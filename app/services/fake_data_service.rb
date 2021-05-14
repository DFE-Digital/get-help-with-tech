class FakeDataService
  def self.generate!(mobile_network_id:, responsible_body_id:, extra_mobile_data_requests: 10, created_by_user_id: nil)
    extra_mobile_data_requests.times do
      r = build_request(mobile_network_id: mobile_network_id, responsible_body_id: responsible_body_id, created_by_user_id: created_by_user_id)
      r.save!
      r.update!(created_at: Time.zone.now.utc - rand(500_000).seconds)
      Rails.logger.info "created #{r.id} - #{r.account_holder_name}"
    end
  end

  def self.build_request(mobile_network_id:, responsible_body_id:, created_by_user_id: nil)
    r = ExtraMobileDataRequest.new(
      account_holder_name: Faker::Name.name,
      device_phone_number: Faker::PhoneNumber.cell_phone,
      agrees_with_privacy_statement: true,
      mobile_network_id: mobile_network_id,
      contract_type: ExtraMobileDataRequest.contract_types.values.sample,
      status: ExtraMobileDataRequest.statuses.values.sample,
      responsible_body_id: responsible_body_id,
      created_by_user_id: created_by_user_id || User.where(responsible_body_id: responsible_body_id).pluck(:id).sample,
    )
    # Very occasionally we get build failures on CI due to an invalid phone number -
    # they go away on subsequent runs. So if that happens, retry up to 100 times
    if !r.valid? && r.errors[:device_phone_number].present?
      generate_valid_phone_number(r)
    end
    r
  end

  def self.generate_valid_phone_number(extra_mobile_data_request)
    i = 0
    while !extra_mobile_data_request.valid? && extra_mobile_data_request.errors[:device_phone_number].present?
      extra_mobile_data_request.device_phone_number = Faker::PhoneNumber.cell_phone
      i += 1
      raise(ArgumentError, "Could not generate valid device_phone_number after 100 attempts #{r.device_phone_number}") if i > 100
    end
  end
end
