FactoryBot.define do
  factory :staged_trust, class: 'DataStage::Trust' do
    gias_group_uid { Faker::Number.number(digits: 6) }
    name { Faker::Educator.secondary_school }
    organisation_type { Trust.organisation_types.values.sample }
    companies_house_number { Faker::Number.leading_zero_number(digits: 8) }

    address_1 { Faker::Address.street_name }
    address_2 { Faker::Address.secondary_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }
    status { :open }

    trait :closed do
      status { :closed }
    end
  end
end
