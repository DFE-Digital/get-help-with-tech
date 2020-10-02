FactoryBot.define do
  factory :staged_school, class: 'DataStage::School' do
    urn { Faker::Number.number(digits: 6) }
    name { Faker::Educator.secondary_school }
    responsible_body_name { Faker::Company.name }
    phase { School.phases.values.sample }
    establishment_type { School.establishment_types.values.sample }

    address_1 { Faker::Address.street_name }
    address_2 { Faker::Address.secondary_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }

    status { :open }

    trait :primary do
      phase { :primary }
    end

    trait :secondary do
      phase { :secondary }
    end

    trait :academy do
      establishment_type { :academy }
    end

    trait :la_maintained do
      establishment_type { :local_authority }
    end

    trait :closed do
      status { :closed }
    end
  end
end
