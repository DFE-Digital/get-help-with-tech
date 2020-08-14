FactoryBot.define do
  factory :school do
    association :responsible_body, factory: %i[local_authority trust].sample
    urn { Faker::Number.number(digits: 5) }
    name { Faker::Educator.secondary_school }
    computacenter_reference { Faker::Number.number(digits: 8) }
  end
end
