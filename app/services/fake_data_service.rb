class FakeDataService
  def self.generate!(recipients: 10, mobile_network_id:, created_by_user_id: nil)
    recipients.times do
      name = Faker::Name.name
      r = Recipient.create!(
        device_phone_number: Faker::PhoneNumber.cell_phone,
        can_access_hotspot: true,
        is_account_holder: true,
        account_holder_name: name,
        privacy_statement_sent_to_family: true,
        understands_how_pii_will_be_used: true,
        mobile_network_id: mobile_network_id,
        status: Recipient.statuses.values.sample,
        created_by_user_id: created_by_user_id,
      )
      r.update(created_at: Time.now.utc - rand(500_000).seconds)
      Rails.logger.info "created #{r.id} - #{r.account_holder_name}"
    end
  end
end
