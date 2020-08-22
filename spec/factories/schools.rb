FactoryBot.define do
  factory :school do
    association :responsible_body, factory: %i[local_authority trust].sample
    urn { Faker::Number.number(digits: 6) }
    name { Faker::Educator.secondary_school }
    computacenter_reference { Faker::Number.number(digits: 8) }

    trait :with_preorder_information do
      preorder_information
    end
  end
end
