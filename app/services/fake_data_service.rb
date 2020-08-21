class FakeDataService
  def self.generate!(extra_mobile_data_requests: 10, mobile_network_id:, created_by_user_id: nil)
    extra_mobile_data_requests.times do
      name = Faker::Name.name
      r = ExtraMobileDataRequest.create!(
        device_phone_number: Faker::PhoneNumber.cell_phone,
        account_holder_name: name,
        agrees_with_privacy_statement: true,
        mobile_network_id: mobile_network_id,
        contract_type: ExtraMobileDataRequest.contract_types.values.sample,
        status: ExtraMobileDataRequest.statuses.values.sample,
        created_by_user_id: created_by_user_id,
      )
      r.update!(created_at: Time.zone.now.utc - rand(500_000).seconds)
      r.update!(problem: ExtraMobileDataRequest.problems.values.sample) if r.queried?
      Rails.logger.info "created #{r.id} - #{r.account_holder_name}"
    end
  end
end
