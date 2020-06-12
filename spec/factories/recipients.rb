FactoryBot.define do
  factory :recipient, class: 'Recipient' do
    full_name                         { "John Johnson" }
    address                           { "22 Acacia Avenue\r\nSometown" }
    postcode                          { "SOM3 T0WN" }
    can_access_hotspot                { true }
    is_account_holder                 { true }
    account_holder_name               { "" }
    device_phone_number               { "07123 456789" }
    privacy_statement_sent_to_family  { true }
    understands_how_pii_will_be_used  { true }
    association :mobile_network
  end
end
