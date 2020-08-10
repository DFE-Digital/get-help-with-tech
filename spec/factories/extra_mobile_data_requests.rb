FactoryBot.define do
  factory :extra_mobile_data_request, class: 'ExtraMobileDataRequest' do
    account_holder_name               { Faker::Name.name }
    device_phone_number               { '07123 456789' }
    agrees_with_privacy_statement     { true }
    status                            { :requested }
    problem                           { nil }
    contract_type                     { :pay_as_you_go }
    association :mobile_network
    association :created_by_user, factory: :local_authority_user

    trait :with_problem do
      status  { :queried }
      problem { ExtraMobileDataRequest.problems.keys.sample }
    end

    trait :mno_not_participating do
      association :mobile_network, factory: %i[mobile_network maybe_participating_in_pilot]
    end
  end
end
