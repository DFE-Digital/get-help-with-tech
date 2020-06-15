class FakeDataService
  def self.generate!(recipients: 10, mobile_network_id:)
    recipients.times do |i|
      name = Faker::Name.name
      r = Recipient.create!(
        full_name: name,
        device_phone_number: Faker::PhoneNumber.cell_phone,
        address: [Faker::Address.street_address, Faker::Address.city].join("\n"),
        postcode: Faker::Address.postcode,
        can_access_hotspot: true,
        is_account_holder: true,
        privacy_statement_sent_to_family: true,
        understands_how_pii_will_be_used: true,
        mobile_network_id: mobile_network_id
      )
      puts "created #{r.id} - #{r.full_name}"
    end
  end
end
