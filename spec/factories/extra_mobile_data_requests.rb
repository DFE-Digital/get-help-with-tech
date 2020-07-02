FactoryBot.define do
  factory :extra_mobile_data_request, class: 'ExtraMobileDataRequest' do
    can_access_hotspot                { true }
    is_account_holder                 { true }
    account_holder_name               { Faker::Name.name }
    device_phone_number               { '07123 456789' }
    privacy_statement_sent_to_family  { true }
    understands_how_pii_will_be_used  { true }
    status                            { :requested }
    association :mobile_network
    association :created_by_user, factory: :local_authority_user
  end
end
