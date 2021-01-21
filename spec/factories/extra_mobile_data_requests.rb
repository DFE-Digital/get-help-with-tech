FactoryBot.define do
  factory :extra_mobile_data_request, class: 'ExtraMobileDataRequest' do
    account_holder_name               { Faker::Name.name }
    device_phone_number               { Faker::Base.numerify('07891 ######') }
    agrees_with_privacy_statement     { true }
    status                            { :new }
    contract_type                     { :pay_as_you_go_payg }
    responsible_body                  { created_by_user&.responsible_body }
    association :mobile_network
    association :created_by_user, factory: :local_authority_user

    trait :with_problem do
      status { ExtraMobileDataRequest.problem_statuses.sample }
    end

    trait :mno_not_participating do
      association :mobile_network, factory: %i[mobile_network maybe_participating_in_pilot]
    end
  end
end
